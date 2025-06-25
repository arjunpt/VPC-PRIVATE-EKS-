# 📦 VPC-PRIVATE-FOR-EKS

A breakdown of why and how we design a secure VPC setup for running **Amazon EKS** using **private subnets**, **NAT**, and **internet gateways**, along with Terraform implementation concepts.

![image](https://github.com/user-attachments/assets/94b5f83a-c5f8-482c-a4ee-c38ac7da26e3)

---

## 🔁 Workflow Breakdown: Why You Need Each Part

### 🔹 1. VPC (Virtual Private Cloud)
Think of it as your own private data center inside AWS.

You control:

- The IP address ranges (via CIDR block)
- Subnet structure
- Internet access rules
- Security via firewall (Security Groups/NACLs)

---

### 🔹 2. Subnets – Public and Private

#### 📤 Public Subnet
A subnet where resources need **direct internet access**, e.g.:

- Load Balancers
- NAT Gateway
- Bastion Host (Jump Server)

> Connected to an **Internet Gateway** (via a public route table).

#### 🔐 Private Subnet
Resources here **do not have direct internet access**. Typically used for:

- App servers
- Databases
- EKS worker nodes

However, these private resources still need **outbound internet access** (e.g., to install packages, pull images), which is provided by the **NAT Gateway**.

---

#### 🔹 3. Internet Gateway (IGW)
Acts as a **door to the internet** for your VPC.

- Only **public subnets** can route traffic through the IGW.
- Required for:
  - Inbound internet access
  - Outbound internet access from public subnets

route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

#### 🔹 4. Elastic IP + NAT Gateway

The **NAT Gateway** sits in a public subnet and allows **private subnet resources** to securely reach the internet.

📦 Example Use Cases:
- Download OS updates
- Pull code from GitHub
- Call external APIs

> NAT Gateway sends **requests out**, but **does not allow inbound traffic**, making it secure.

---

#### 🔹 5. Route Tables

Each subnet requires a route table to determine how traffic flows.

| Subnet Type     | Route Destination | Target           | Purpose                             |
|------------------|-------------------|------------------|-------------------------------------|
| Public Subnet    | `0.0.0.0/0`       | Internet Gateway | Outbound & Inbound to Internet      |
| Private Subnet   | `0.0.0.0/0`       | NAT Gateway      | Outbound-only to Internet           |

---

#### 🔹 6. Why Use This Structure?

| Resource Type        | Placed In       | Why                                                                 |
|----------------------|-----------------|----------------------------------------------------------------------|
| Load Balancer        | Public Subnet   | Needs to receive internet traffic                                   |
| EKS Worker Nodes     | Private Subnet  | Should be isolated from direct internet access                      |
| NAT Gateway          | Public Subnet   | Needs internet access and connects private subnet outbound traffic  |
| Database (e.g., RDS) | Private Subnet  | Should **never** be exposed to the public internet                  |
| Bastion Host (SSH)   | Public Subnet   | DevOps teams can access internal resources securely via jump host   |
| Security Groups      | All             | Control traffic at instance level (like firewalls)                  |

---

#### 🔄 Putting It All Together: Real-Life Use Case

Let’s say you’re deploying an **Amazon EKS (Kubernetes)** cluster:

- ✅ Control Plane is **managed by AWS**
- 🔒 Worker Nodes are placed in **private subnets** for security
- 🌐 Load Balancer (e.g., ALB) is deployed in **public subnet**
- 🔁 Private nodes still access the internet **via NAT Gateway** to:
  - Pull container images
  - Download OS and package updates

---

#### 🧠 Terraform Concepts Used

| Feature        | Purpose                                                  |
|----------------|----------------------------------------------------------|
| `count`        | Loops resource creation (e.g., subnets, associations)    |
| `count.index`  | Gets index in the loop (0, 1, 2...)                       |
| `element()`    | Picks item from a list using index (e.g., AZs, CIDRs)    |
| `depends_on`   | Explicitly sets resource dependency ordering             |


