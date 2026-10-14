# Project Write-Up: Advanced VLAN Segmentation & Stateful Firewall Isolation

## 1. Objective
Enterprise networks routinely house mismatched security postures under one roof (e.g., untrusted consumer Smart IoT sensors, untrustworthy guest clients, production lab infrastructure, and daily endpoints). If left flat, a single vulnerability in a smart lightbulb compromises the entire domain. 

The objective of this project was to slice a flat physical switched layout into **four separate virtual local area networks (VLANs)**, enforce localized dynamic IP provisioning, and author an iron-clad **Access Control List (ACL)** security topology on our Cisco 1921 core routing engine to manage zero-trust network boundaries.

## 2. Technologies Used
*   **Cisco IOS Software (Inter-VLAN Sub-interfaces)**
*   **Cisco Catalyst Switching Features (802.1Q Tagging, Trunk Port Profiles, Access Ranges)**
*   **Extended Access Control Lists (Stateful Traffic Evaluation Filtering)**
*   **Cisco IOS DHCP Server Pools & IP Address Overload Translation Engine (NAT)**
*   **PuTTY Terminal Emulator** via Serial USB-to-RJ45 Hardware Links

## 3. Step-by-Step Implementation

### Phase A: Slicing the Layer 2 Fabric (Cisco Switches)
Using the `interface range` configuration primitives, the ports on the primary 2960 and stacked secondary 3750 switches were cut in half to enforce explicit network separation:

```unset
! Partitioning the Primary 2960 Switch 50/50
interface range fastethernet 0/1 - 12
 switchport mode access
 switchport access vlan 10
!
interface range fastethernet 0/13 - 24
 switchport mode access
 switchport access vlan 20
```

The underlying daisy chain trunk connection between switches was established via 802.1Q tagged configurations. On the Cisco 3750 multi-layer switch, legacy ISL protocols had to be overridden by explicitly defining native `dot1q` framing structures:

```unset
! Establishing multi-VLAN trunk highway on the 3750 Stack port
interface fastethernet 2/0/1
 switchport trunk encapsulation dot1q
 switchport mode trunk
 no shutdown
```

### Phase B: Gateways and Server Pools Configuration (Cisco 1921 Router)
The router physical interface `GigabitEthernet 0/1` was abstracted into virtual logical subinterfaces matching our dot1Q tagging matrix:

```unset
interface gigabitethernet 0/1.30
 encapsulation dot1Q 30
 ip address 192.168.30.1 255.255.255.0
 ip nat inside
!
interface gigabitethernet 0/1.50
 encapsulation dot1Q 50
 ip address 192.168.50.1 255.255.255.0
 ip nat inside
```
*Matching automated IP scopes (`ip dhcp pool`) were established alongside explicit network exclusion markers (`ip dhcp excluded-address`) to safeguard gateway endpoints.*

---

## 4. Challenges & Troubleshooting (Crucial)

### 🚨 The Blind Block Trap (The Two-Way Street Problem)
**The Problem:** When implementing the safety isolation matrices, the core requirement was defined as: *"VLAN 10 must be allowed full access into the Server Lab (VLAN 50), but VLAN 50 must be completely blocked from talking into the sensitive Home/Lab environment (VLAN 10)."* 

Initially, an absolute deny ACL statement was drafted inbound on the VLAN 50 gateway interface:
```unset
! FAILED CONFIGURATION - TRAFFIC TIMED OUT
ip access-list extended VLAN50_IN
 deny ip any 192.168.10.0 0.0.0.255
 permit ip any any
```
This cleanly blocked unintended traffic from VLAN 50. However, when initiating an administrative connection from an authorized computer on VLAN 10 down into a server on VLAN 50, **the connection dropped entirely**. 

**The Diagnostic Methodology:** Network routing was verified, and the computer pulled its address pool perfectly. By executing systematic terminal tracing, it was determined that network communications are stateful two-way transactions. VLAN 10 sent out an access frame successfully, the server processed it, and compiled a reply packet. However, when the server's reply attempted to re-enter the router gateway interface, the strict `deny ip any 192.168.10.0` directive saw a frame bound for a VLAN 10 IP address and dropped it.

**The Fix:** The implementation was converted into a stateful framework by rewriting the Access Control List to utilize the **TCP `established` keyword parameter**. 

```unset
! CORRECTED LIVE STATEFUL IMPLEMENTATION
ip access-list extended VLAN50_IN
 deny ip any 192.168.20.0 0.0.0.255  ! Block Servers from touching Guest
 deny ip any 192.168.30.0 0.0.0.255  ! Block Servers from touching IoT
 permit tcp any 192.168.10.0 0.0.0.255 established ! PERMIT RETURN-TRIP REPLIES ONLY
 deny ip any 192.168.10.0 0.0.0.255  ! Hard Block independent server scans into VLAN 10
 permit ip any any                   ! Allow out to Open Web via NAT
```
The `established` rule commands the router's processor to look at the TCP control flag headers. If the packet is part of a session that was **already started by a VLAN 10 node** (possessing active ACK or RST flags), it bypasses the block gate. If a server inside VLAN 50 attempts to start a brand new connection into VLAN 10 independently, the rule is ignored, it hits the absolute deny, and gets blocked.

---

## 5. Key Takeaways
1. **Network Separation Mastery:** Gained hands-on experience using the `interface range` shortcut to isolate broadcast domains without changing physical layouts.
2. **Stateful Filtering Paradigms:** Learned that writing network security rules requires tracking full round-trip packet lifetimes rather than mapping single-directional rules.
3. **Legacy Hardware Idiosyncrasies:** Addressed specialized interface numbering variations caused by stacked member memory states (`Fa2/0/X`) and explicit frame trunk standardizing (`dot1q encapsulation`) required on high-tier multi-layer enterprise routing switches.
