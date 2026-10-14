# 🛠️ Enterprise Homelab Network Infrastructure

## 1. Home / Dashboard (The "Hook")

### 🌐 The Big Picture
This homelab is a production-grade, sandboxed network infrastructure built from the ground up using enterprise-grade Cisco hardware. The objective of this project is to master fundamental and advanced concepts in **Layer 2 switching, Layer 3 routing, stateful packet filtering (firewalls), and network segmentation**. 

By moving away from consumer "plug-and-play" gear, this environment mirrors enterprise network architectures, providing hands-on validation for real-world business infrastructure, security policies, and performance engineering.

### 📊 Current State & Topology Specs
*   **Infrastructure Model:** Multi-Switch Layer 2 Access / Layer 3 Border Core Architecture (Router-on-a-Stick).
*   **Logical Networks Hosted:** 4 Fully Isolated Virtual LANs (VLANs) segmenting endpoint traffic classes.
*   **State:** 🟢 Active / Live Production

### 🗺️ Network Architecture Diagram

![Network Map](./network_map.drawio.png)

## 2. Architecture & Hardware (The "What")

### 🔩 Hardware Specifications
*   **Edge Router/Gateway:** Cisco 1921 Integrated Services Router (ISR G2) equipped with dual onboard 10/100/1000Mbps routed ports and expansion EHWIC slots.
*   **Primary Distribution Switch:** Cisco Catalyst 2960 Series Layer 2 Switch (24x FastEthernet Access Ports, 2x Gigabit Ethernet Uplinks).
*   **Secondary Expansion Switch:** Cisco Catalyst 3750 Multi-Layer Switch (Configured as a member of an abstracted stack topology running interface member prefix `Fa2/0/X`).

### 📦 Core Infrastructure Services
*   **Routing Engine:** Cisco IOS Software (Inter-VLAN subinterface routing on router 802.1Q sub-ports).
*   **Addressing Architecture:** Stateful **Cisco IOS DHCP Server Daemon** utilizing localized allocation scopes per VLAN pool.
*   **Network Address Translation (NAT):** Dynamic NAT Overload (PAT) running at the Cisco 1921 edge to bind multi-VLAN private blocks to a single dynamic public ISP gateway.
*   **Security Protocol:** Extended inbound Cisco Access Control Lists (ACLs) acting as a stateful border firewall.

---

## 3. Project Log / Detailed Write-Ups (The "How")

### 📂 Security & Networking
*   **[Project 01: Core Network Building & Password Recovery](./projects/cisco-core-setup.md)** — Overcoming legacy hardware state-locks, baseline provisioning, and multi-tier trunk configurations.
*   **[Project 02: Advanced VLAN Segmentation & Stateful Firewall Policy](./projects/cisco-acl-firewall.md)** — Architecting a zero-trust multi-VLAN paradigm and debugging asymmetrical traffic return paths using stateful packet inspection strings.

---

## 4. "What I'm Learning Next" / Roadmap (The Future)
*   **[ ] Migration to Layer 3 Switching (Topology 2):** Wipe router-on-a-stick configurations to delegate inner-core Inter-VLAN routing natively to the Cisco 3750 multi-layer switch hardware using Switch Virtual Interfaces (SVIs) and Point-to-Point routed lines for raw wire-speed throughput optimizations.
*   **[ ] Remote Infrastructure Management:** Provisions secure AAA profiles and SSHv2 encrypted terminal layers across lines vty 0-4 to safely retire raw physical console cables.
*   **[ ] Localized Infrastructure Services Deployment:** Introducing a bare-metal hypervisor node (Proxmox/Ubuntu server) running localized upstream containerized DNS filters (Pi-Hole/AdGuard Home) alongside central NAS utilities.
