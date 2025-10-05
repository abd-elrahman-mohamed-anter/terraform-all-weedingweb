
# Wedding Website Deployment

✨ This repository demonstrates deploying a **2-tier wedding website** on AWS using **Terraform**.

---

## 🎥 Visual Demo

If you are a visual learner, you can see a demo of the live website served via AWS Load Balancer:

![Website Demo](front.png)

---

## 🔹 Architecture Overview

* **2-tier application**

  * **Web Tier:** EC2 instances running the wedding website, behind an **Application Load Balancer (ALB)**
  * **Database Tier:** MySQL RDS instance in private subnets
* **Networking**

  * Public and private subnets in a VPC, with security groups for access control
  * ALB routing HTTP traffic to the web tier
* **Auto Scaling**

  * Auto Scaling Group (ASG) automatically adjusts the number of instances based on **CPU utilization**
* **CDN**

  * **CloudFront distribution** provides **fast global delivery** and reduces latency by caching content closer to users

**Screenshots from AWS:**

* Load Balancer List: ![Load Balancers](lb.png)
* Load Balancer Details: ![ALB Details](enter-lb.png)
* CloudFront Distribution: ![CloudFront](cloudfront.png)
* Website Frontend: ![Website](front.png)

---

## 🗂️ Project Setup

### 1. Configure Variables

Edit `terraform.tfvars` in the `root` directory with your environment values:

```hcl
region = "us-east-1"
project_name = "wedding-website"
vpc_cidr = "10.0.0.0/16"

pub_sub_1a_cidr = "10.0.1.0/24"
pub_sub_2b_cidr = "10.0.2.0/24"
pri_sub_3a_cidr = "10.0.3.0/24"
pri_sub_4b_cidr = "10.0.4.0/24"
pri_sub_5a_cidr = "10.0.5.0/24"
pri_sub_6b_cidr = "10.0.6.0/24"

db_username = "admin"
db_password = "pass"
```

### 2. Initialize and Deploy

Go to the `root` folder:

```sh
cd root
terraform init
terraform plan
terraform apply
```

Type `yes` to confirm deployment.

---

## ⚠️ Notes

* `.gitignore` is included to avoid uploading sensitive files:

```gitignore
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
terraform.tfvars
crash.log
```

* CloudFront and RDS may have **Free Tier restrictions**, so ensure your AWS account supports the chosen instance sizes.

* Auto Scaling Group automatically scales **web instances** up or down depending on load.

---

## 💡 Author

* **Abd Elrahman Mohamed Anter**
* Contact: [Linkedin](www.linkedin.com/in/abd-elrahman-mohamed-anter)

---

**Thank you so much for reading..😅**
