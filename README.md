# ABC Technologies — Corporate Website DevOps Project
### Use Case 1: Corporate Company Website Deployment

A static corporate website (Home, About Us, Services, Careers, Gallery, Contact Us)
deployed through a complete DevOps pipeline: **Git → Jenkins → Docker → Kubernetes**,
with **Nagios, Graphite, and Grafana** for continuous monitoring.

---

## 1. Project Structure

```
.
├── website/                  # Static site (HTML, CSS, JS, images)
├── Dockerfile                # Builds an nginx image serving the website
├── nginx.conf                # Adds /healthz and /nginx_status endpoints
├── Jenkinsfile                # CI/CD pipeline: build → push → deploy → smoke test
├── k8s/
│   ├── deployment.yaml        # 3-replica Deployment with liveness/readiness probes
│   └── service.yaml           # NodePort Service (port 30080)
└── monitoring/
    ├── nagios/abc-website.cfg              # Host + HTTP + PING checks
    ├── graphite/push_metrics_to_graphite.sh # Pushes metrics to Carbon (port 2003)
    └── grafana/abc-website-dashboard.json   # Dashboard: CPU, Memory, Network, Availability, Uptime
```

## 2. Prerequisites

- Git and a GitHub account
- Docker Desktop / Docker Engine
- A Kubernetes cluster (Minikube is easiest for local demos: `minikube start`)
- Jenkins (local install or Docker container) with the Docker and Kubernetes CLI plugins
- A Docker Hub account (for image push)
- Nagios Core, Graphite (Carbon + web UI), and Grafana — installed locally or via Docker

## 3. Step-by-Step Implementation

### Step 1 — Version Control (Git/GitHub)
```bash
git init
git add .
git commit -m "Initial commit: ABC Technologies corporate website"
git branch -M main
git remote add origin https://github.com/<YOUR_USERNAME>/<REGISTER_NUMBER>-DevOps-Project.git
git push -u origin main
```
📸 Screenshot: GitHub repository showing pushed files.

### Step 2 — Build and Run Locally with Docker
```bash
docker build -t abc-corporate-website:latest .
docker run -d -p 8080:80 --name abc-website abc-corporate-website:latest
```
Visit `http://localhost:8080` to confirm the site loads.
📸 Screenshots: `docker build` output, `docker ps` showing the running container, browser view.

### Step 3 — Push to Docker Hub
```bash
docker login
docker tag abc-corporate-website:latest <DOCKERHUB_USERNAME>/abc-corporate-website:latest
docker push <DOCKERHUB_USERNAME>/abc-corporate-website:latest
```
📸 Screenshot: Docker Hub repository page showing the pushed image.

### Step 4 — Jenkins CI/CD Pipeline
1. Install Jenkins, then install the **Docker Pipeline** and **Kubernetes CLI** plugins.
2. Add credentials: Docker Hub username/password as `dockerhub-creds` (Manage Jenkins → Credentials).
3. Create a new **Pipeline** job pointing to this GitHub repo, using the included `Jenkinsfile`.
4. Update the placeholders in `Jenkinsfile` (`<YOUR_USERNAME>`, `<YOUR_REPO>`, `<DOCKERHUB_USERNAME>`).
5. Trigger a build (or configure a GitHub webhook so every push auto-builds).
📸 Screenshots: Jenkins Dashboard, Job Configuration, Console Output, Successful Build.

### Step 5 — Deploy to Kubernetes
```bash
minikube start
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get svc
minikube service abc-website-service --url
```
📸 Screenshots: `kubectl get pods` (Running), `kubectl get svc` (NodePort), browser view of the site via the NodePort URL.

### Step 6 — Nagios Monitoring
1. Copy `monitoring/nagios/abc-website.cfg` into your Nagios `objects/` directory and reference it from `nagios.cfg`.
2. Replace `<NODE_IP>` with your Minikube/host IP (`minikube ip`).
3. Validate and restart:
   ```bash
   /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
   sudo systemctl restart nagios
   ```
📸 Screenshot: Nagios web UI showing `abc-website-host` UP and services OK.

### Step 7 — Graphite Metrics
1. Run Graphite/Carbon (e.g. `docker run -d --name graphite -p 80:80 -p 2003-2004:2003-2004 graphiteapp/graphite-statsd`).
2. Run the metrics pusher on a schedule (cron every minute):
   ```bash
   */1 * * * * /path/to/monitoring/graphite/push_metrics_to_graphite.sh <GRAPHITE_HOST> http://<NODE_IP>:30080
   ```
📸 Screenshot: Graphite web UI (Composer) showing `abc_website.*` metrics.

### Step 8 — Grafana Dashboard
1. Run Grafana (e.g. `docker run -d -p 3000:3000 grafana/grafana`).
2. Add a **Graphite** data source pointing at your Graphite server.
3. Import `monitoring/grafana/abc-website-dashboard.json` (Dashboards → Import → Upload JSON).
📸 Screenshot: Grafana dashboard showing CPU, Memory, Network, HTTP Availability, and Uptime panels.

## 4. Mandatory Submission Links (fill in before submitting)

| Item | Link |
|---|---|
| GitHub Repository | `https://github.com/<YOUR_USERNAME>/<REGISTER_NUMBER>-DevOps-Project` |
| Jenkins Build URL | `<JENKINS_URL>` or screenshots if local |
| Docker Hub Repository (optional) | `https://hub.docker.com/r/<DOCKERHUB_USERNAME>/abc-corporate-website` |
| Application URL | `http://<NODE_IP>:30080` or `http://localhost:8080` |
| Grafana Dashboard | Screenshot |
| Nagios Monitoring | Screenshot |
| Graphite Metrics | Screenshot |

## 5. Notes

- `/healthz` on the nginx container is used by Docker's `HEALTHCHECK`, Kubernetes liveness/readiness probes, and the Nagios `check_http` command — one endpoint, three consumers.
- `/nginx_status` (nginx `stub_status`) is the source for the connection-count metric pushed to Graphite.
- Replace every placeholder in angle brackets (`<...>`) with your actual values before running.
