# &#128216; 07-03: Cloud & Virtualization

<!-- course-header -->
<div align="center" markdown>

![SQL & Databases](../assets/banner.svg)

<img src="https://img.shields.io/badge/Module_07-Data_Warehousing_BI-336791?style=for-the-badge&labelColor=24506B" alt="Module 07: Data Warehousing, BI & Big Data">

[![Home](https://img.shields.io/badge/⌂_Home-1B2A35?style=flat-square)](../index.md) [![All Notes](https://img.shields.io/badge/All_Notes-1B2A35?style=flat-square)](README.md) [![Practice](https://img.shields.io/badge/✎_Practice-C6821E?style=flat-square&labelColor=24506B)](../02-exercises/07-exercise.md) [![Quiz](https://img.shields.io/badge/▶_Quiz-C6821E?style=flat-square&labelColor=24506B)](../03-quiz/)

</div>
<!-- /course-header -->

## &#128161; Where Warehouses Actually Live

A data warehouse has to run *somewhere* — on physical hardware in a data center. Almost nobody buys that hardware outright anymore; instead, they rent computing capacity from someone who already built the data center. Understanding *how* that renting works — virtualization and cloud service models — is directly useful to a data person, because "where do I run Postgres" is a decision you'll actually make.

---

## &#128204; Virtualization

**Virtualization** means using software to simulate hardware that isn't really there — one physical machine pretending to be several independent machines. This is what makes cloud computing economical: a provider's physical server can be sliced up and rented out to many customers at once, each believing they have their own dedicated machine.

- The physical machine is the **host**.
- Each simulated machine is a **virtual machine (VM)**.
- The software that creates and manages VMs is a **hypervisor**, and there are two kinds:
  - **Type 1 ("bare metal")** — the hypervisor runs directly on the hardware, no host OS underneath. Used in data centers (VMware ESXi, Microsoft Hyper-V Server) because of the performance and isolation it provides.
  - **Type 2 ("hosted")** — the hypervisor runs as an application on top of a regular host OS (VirtualBox, VMware Workstation, Parallels). This is what a student runs on their own laptop to spin up a Linux VM for coursework.

### VMs vs. containers

A VM virtualizes an entire computer, including its own kernel — heavy, but fully isolated. A **container** (Docker being the dominant example) virtualizes at a lighter level: containers share the host machine's kernel and only package the application plus its dependencies. Containers start in milliseconds instead of minutes and use a fraction of the disk/memory a VM needs, at the cost of slightly weaker isolation than a full VM.

This is directly relevant to how you've likely been running PostgreSQL in this course: `docker run postgres` starts a **container**, not a VM — Postgres and its dependencies are packaged together and share your machine's kernel, which is why it starts up almost instantly and why the same container image behaves identically on your laptop, a teammate's laptop, and a production server.

> [!TIP]
> Rule of thumb: reach for a **VM** when you need to run a different operating system entirely or need strong isolation between tenants; reach for a **container** when you just need to package "my app plus its exact dependencies" so it runs identically everywhere. Most modern database dev workflows (including this course's) use containers for exactly that reason.

---

## &#128204; Cloud Service Models

Cloud providers sell computing capacity at different levels of "how much do you manage yourself." The three classic tiers:

| Model | You manage | Provider manages | Example |
|---|---|---|---|
| **IaaS** (Infrastructure as a Service) | OS, database software, your app | Physical hardware, networking, virtualization | A raw EC2 / Azure VM instance |
| **PaaS** (Platform as a Service) | Just your application and data | OS, runtime, patching, and (often) the database engine itself | Heroku, managed Kubernetes, App Service |
| **SaaS** (Software as a Service) | Nothing — you just use it | Everything, including the application | Salesforce, Gmail, a hosted BI dashboard |

Moving down that table, you give up control but also give up operational burden. IaaS gives you the most flexibility (install anything) at the cost of having to patch and secure it yourself; SaaS gives you zero setup at the cost of zero customization.

### Deployment models

Separately from *how much* is managed for you, there's *who else shares the infrastructure*:

- **Public cloud** — shared infrastructure, multiple customers, pay-as-you-go (AWS, Azure, GCP).
- **Private cloud** — dedicated infrastructure for one organization, either on-premises or hosted, used when compliance or control requirements are strict.
- **Hybrid cloud** — a mix: some systems on-premises or in a private cloud, others in the public cloud, connected together (e.g., keep sensitive data on-prem, burst analytics workloads to the public cloud).

---

## &#128204; Managed Database Services — the Practical Angle

For anyone working with data day to day, the most relevant cloud offering is the **managed database service** — a PaaS-style product where the provider runs the DBMS for you:

- **Amazon RDS** (Relational Database Service) — supports PostgreSQL, MySQL, SQL Server, Oracle, and MariaDB engines.
- **Google Cloud SQL** — the GCP equivalent, same engines.
- **Azure SQL Database** / **Azure Database for PostgreSQL** — the Azure equivalents.

What a managed service takes off your plate: automated backups, patching, replication for high availability, and often automatic storage scaling. What you still own: schema design, query performance, indexing strategy, and access control — everything covered in this course. In practice, "I need a Postgres database for this project" today usually means clicking a few options in one of these services rather than provisioning and patching a server by hand.

> [!NOTE]
> A managed database service is a good example of PaaS: you never see the underlying VM or OS, you just get a connection string, a `CREATE TABLE` prompt, and someone else's on-call rotation handling 3 a.m. disk failures.

---

## &#128204; What's Underneath a Cloud Data Center

It's worth knowing, at a conceptual level, what a cloud provider is actually renting out underneath all of this:

- **Storage area networks (SANs)** — a dedicated network path connecting servers to shared disk arrays, so many physical disks act as one large, fast, centrally-managed pool of storage rather than each server owning its own local drives.
- **RAID (Redundant Array of Independent Disks)** — a way of combining multiple physical disks that can be configured either for maximum speed (striping data across disks) or maximum reliability (mirroring/parity so a single disk failure doesn't lose data). Every managed database service you rent is running on storage configured this way behind the scenes, even though you never see the individual disks.
- **Distributed databases** — a database stored and processed across more than one physical machine, either by **partitioning** (splitting rows/tables across machines) or **replicating** (copying the same data to multiple machines), or both. Cloud-managed databases lean on this heavily for **high availability**: if one machine fails, a replica takes over with minimal (or zero) downtime. This same idea — a database physically spread across a cluster — is also the foundation for the Big Data and NoSQL systems covered in the next note.

> [!TIP]
> None of this changes how you write SQL. The point of a managed cloud database is precisely that RAID, SAN, replication, and failover happen underneath the connection string you're handed — you design schemas and write queries exactly as you have all course, and the provider's infrastructure choices stay invisible unless something goes wrong.

---

See also: [OLAP vs. OLTP & BI](07-02-olap-vs-oltp-and-bi.md), [Big Data & NoSQL](07-04-big-data-and-nosql.md)

<!-- course-footer -->
---

<div align="center" markdown>

[All Notes](README.md) &nbsp;|&nbsp; [Module 07 Exercise](../02-exercises/07-exercise.md) &nbsp;|&nbsp; <strong>Next:</strong> [Big Data & NoSQL](07-04-big-data-and-nosql.md)

</div>
<!-- /course-footer -->
