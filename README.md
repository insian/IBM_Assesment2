# IBM Asessment 2
# Running a Python Web App on Docker, Kubernetes, and Minikube

In this guide, we'll walk through the steps to run a Python web application on Docker, Kubernetes, and Minikube.

## Running on Docker

1. **Dockerize the Python Web App**:
   - Create a Dockerfile in the root directory of your Python web app.
   - Use a base Python image (`python:3.9`, for example).
   - Copy your application code into the Docker image.
   - Install dependencies using `pip`.
   - Expose the necessary port (e.g., port 5000).
   - Define the command to run the application (`CMD python app.py`).

2. **Build the Docker Image**: give the image name as `<docker-username>/<imagename>:<version>`
   ```bash
   docker build -t <image name> .
   ```

4. **Run the Docker Image**:
   ```bash
   docker run -p <anyport>:5000 -it <image name>
   ```
   the application should be available at `http://localhost:<anyport>`

5. **Push the Image to Docker Hub**
   ```bash
   docker push <image name>
   ```

## Running on Kubernetes

### Deploying to Kubernetes

1. **Create Kubernetes Deployment and Service YAML Files**:
   - Create `deployment.yaml` and `service.yaml` files to define the deployment and service configurations, respectively.

2. **Define the Deployment Spec**:
   - In `deployment.yaml`, specify the deployment spec including container image, ports, replicas, etc.

3. **Define the Service Spec**:
   - In `service.yaml`, define the service spec to expose the deployment.

4. **Apply the Kubernetes Configuration** - Apply the Kubernetes configuration using the following command:
    ```bash
    kubectl apply -f deployment.yaml -f service.yaml
    ```
5. **Now you retrieve information about various Kubernetes resources**

   To get information about pods
   ```bash
   kubectl get pods
   ```

   To get information about services
   ```bash
   kubectl get services
   ```


## Running on Minikube

### Start Minikube

Start Minikube using the following command:

```bash
minikube start --driver=docker
```

### Exposing the service

Check the service name by running
```bash
kubectl get services
```

Then to expose the service using minikube run
```bash
minikube service <service-name>
```

# Running Terraform script

to run the terraform script to create a VPC, EC2 and RDS run the following one by one
```bash
terraform init

terraform plan

terraform apply

#to destroy all resources
terraform destroy
```
