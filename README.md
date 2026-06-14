
<div align="center">
  <h1>🚨 K8s Warning Monitor MCP</h1>
  <p><b>A custom Model Context Protocol (MCP) server for intelligent Kubernetes cluster diagnostics.</b></p>
  
  ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
  ![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
  ![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
</div>

---

## 📖 Overview

The **K8s Warning Monitor** is a purpose-built Model Context Protocol (MCP) server that acts as a targeted diagnostic bridge between your local Kubernetes cluster (like Minikube) and AI coding assistants (like Cline or Roo Code). 

Instead of flooding the AI's context window with thousands of normal cluster scheduling events, this tool strictly filters for `Warning` or `Failed` events. It parses the data into clean, formatted text, allowing your AI to instantly understand what is currently broken in your environment without wasting tokens.

## ✨ Features

- 🎯 **Context-Optimized:** Only returns actionable warnings (e.g., `ImagePullBackOff`, `CrashLoopBackOff`, `FailedScheduling`).
- 🐳 **Fully Dockerized:** Runs ephemerally as an interactive Docker container.
- 🪟 **Windows 11 & Minikube Friendly:** Includes the exact configuration needed to route container traffic back to a Windows host's Minikube cluster via `host.docker.internal`.
- ⚡ **Automated Lifecycle:** The AI spins the container up to execute the tool, communicates via standard streams (`stdio`), and the `--rm` flag cleans it up immediately after.

---

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Docker Desktop** (running)
- **Minikube** (or any local/remote Kubernetes cluster)
- **kubectl** configured and authenticated
- **VS Code** with the **Cline** (or equivalent MCP-compatible) extension

---

## 🚀 Setup & Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/k8s-warning-monitor.git
cd k8s-warning-monitor
```

### 2. Build the Docker Image
Build the lightweight Node.js Alpine container:
```bash
docker build -t mcp-k8s-warnings .
```

### 3. Prepare the Docker-Friendly Kubeconfig
Because Docker containers have their own isolated network loopback, we need to create a flattened kubeconfig that allows the container to talk to your host's Minikube.

Generate the flattened config (embeds certificates directly):
```bash
kubectl config view --raw --minify --flatten > kubeconfig-docker
```

**⚠️ CRITICAL MINIKUBE FIX:**
Open `kubeconfig-docker` in your editor. Locate the `server:` address (it usually points to `https://127.0.0.1:<port>`). 
Change `127.0.0.1` to `host.docker.internal`.

*Example:*
```yaml
# Change this:
server: https://127.0.0.1:58253
# To this:
server: https://host.docker.internal:58253
```

### 4. Connect to Cline (VS Code)
Open your MCP settings in VS Code (`cline_mcp_settings.json`) and add the server configuration. 

*Note: Update the `D:\study\...` volume path to match your absolute clone directory.*

```json
{
  "mcpServers": {
    "warning-monitor-docker": {
      "command": "docker",
      "args": [
        "run",
        "-i",
        "--rm",
        "-v",
        "D:\path\to\your\clone\k8s-warning-monitor\kubeconfig-docker:/root/.kube/config:ro",
        "mcp-k8s-warnings"
      ]
    }
  }
}
```

---

## 🤖 Usage Examples

Once configured, reload your VS Code window. Open your AI chat interface and try the following prompts:

> 🗣️ *"Using the warning-monitor-docker tool, get my cluster errors."*

> 🗣️ *"Check if there are any failing pods in the cluster, then suggest a fix for the highest priority warning."*

> 🗣️ *"Run a cluster health check using the warning monitor tool."*

---

## 🔒 Security & Architecture Note

**Is this safe to run?** The TypeScript code executing inside this container is strictly **read-only**. It only utilizes the `@kubernetes/client-node` API to perform `listEventForAllNamespaces()` requests. The AI has no programmed capability to modify, delete, or create resources through this specific MCP server.

**However, the container itself inherits your privileges.**
Because the installation mounts your local, flattened `kubeconfig-docker` file into the container, the Docker process has the same cluster administrative rights as your local user. For strict enterprise security, you should replace the flattened config with one utilizing a restricted Kubernetes `ServiceAccount` bound to a `ClusterRole` that only permits "get, list, watch" verbs.
