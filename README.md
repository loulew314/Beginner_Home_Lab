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
*Below is the topological map illustrating traffic flowing from the edge ISP demarcation point down to localized endpoints via a multi-tier physical switch array.*
[ 🌐 Internet / ISP Modem ]
│
│ (DHCP Client/Public IP)
[ 🛡️ Cisco 1921 Edge Router ]
│
│ (Gig0/1 - 802.1Q 4x Trunk Trunk Expressway)
│
[ 🔌 Cisco 2960 Primary Switch ]
├── Ports 1-12:  VLAN 10 (Home/Lab Access)
├── Ports 13-24: VLAN 20 (Isolated Guest Access)
└── Port Gig0/2: (Backbone Trunk Extension)
│
│ (Cat5e Physical Jumper Trunk)
│
[ ⚙️ Cisco 3750 Secondary Switch (Stack Member 2) ]
├── Port Fa2/0/1:  Incoming Backbone Trunk
├── Ports 2-12:   VLAN 30 (Isolated IoT Access)
└── Ports 13-24:  VLAN 50 (Server Lab Infrastructure)
