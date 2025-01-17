# Terraform module for deploying the Cisco Kubernetes Demo application

The Cisco Kubernetes demo application consists of multiple building blocks that interact. During your setup of this application you might decide to set up one, a few, or all of the components. You can also set up different components on different clusters and connect them with each other. This documentation will first explain the high-level design of the application before diving into each sub-component and explaining the customization and adaptation options for each of them.

## High-level application design

The application consists of six main building blocks that can be seen in the image below.
![High-level application design](https://github.com/3191110276/terraform-kubernetes-cnb/blob/main/images/high_level_design.png?raw=true)

As you can see, the application has already been created with a specific use case in mind, but all components can be re-named. Thus you can adapt the application to show any use case. By just re-naming this application, it could show a finance use case, a medical use case, or anything else that you might want to demo. Each application component also equals to a namespace in Kubernetes.

The main characteristic you can change about the high-level components is the name of the namespace and whether or not the component should be deployed at all. The name change allows you to adapt the application to different scenarios. You can also decide that components you want to deploy to, for example, split the application up across multiple clusters. Below you can find an overview of the Terraform variables you can use to tune the high-level design:

| Component   | Deploy? (bool)     | Namespace (string)          |
|-------------|--------------------|-----------------------------|
| Trafficgen  | deploy_trafficgen  | trafficgen_namespace        |
| Order       | deploy_order       | order_namespace             |
| ExtPayment  | deploy_extpayment  | extpayment_namespace        |
| ExtProd     | deploy_extprod     | extprod_namespace           |
| Procurement | deploy_procurement | procurement_namespace       |
| Accounting  | deploy_accounting  | accounting_namespace        |


## Component: TrafficGen
The TrafficGen application component is used for generating user traffic to the web frontend (part of the Order application component). This simulated traffic loads the webpage and then generates multiple requests on the page. What happens can be modified in several ways to simulate certain events. You could, for example, change the client response time to simulate Internet connectivity problems. These values have not been exposed yet, but will be avaiable in a future release. Below you can find an overview of all variables you can change and their effect on the generated traffic.

| Variable                | Default                                                | Effect                                                                                |
|-------------------------|--------------------------------------------------------|---------------------------------------------------------------------------------------|
| trafficgen_app_endpoint | "essential-nginx-ingress-ingress-nginx-controller.iks" | The endpoint to which all requests are sent                                           |
| trafficgen_name         | "trafficgen"                                           | The name of the application component in Kubernetes itself                            |
| trafficgen_replicas     | 10                                                     | Simultaneous requests that will be generated. Double the amount is created per minute |

## Component: Order

## Component: ExtPayment
The ExtPayment application component represents an HTTP endpoint that can be connected to from the Order application component. Unlike Order, this component does not have any instrumentation for AppDynamics, thus it will appear like an external call, even if both components are deployed on the same cluster. This component allows for tuning some response time parameters to fake delays when processing the request. You can modify the values in the table below to change the way that ExtPayment looks and behaves.

| Variable                       | Default | Effect                                                                       |
|--------------------------------|---------|------------------------------------------------------------------------------|
| extpayment_name                | payment | Name of ExtPayment - changes how it will show up in UIs like AppDynamics.    |
| extpayment_replicas            | 2       | Copies of the Pod                                                            |
| extpayment_cpu_request         | 100m    | CPU Request for each Pod                                                     |
| extpayment_cpu_limit           | 400m    | CPU Limit for each Pod                                                       |
| extpayment_memory_request      | 128Mi   | Memory Request for each Pod                                                  |
| extpayment_memory_limit        | 512Mi   | Memory Limit for each Pod                                                    |
| extpayment_min_random_delay    | 0       | Minimum average delay for a request in milliseconds                          |
| extpayment_max_random_delay    | 1000    | Maximum average delay for a request in milliseconds                          |
| extpayment_lagspike_percentage | 0.01    | Chance of a lagspike happening per request                                   |

## Component: ExtProd
The ExtProd application component represents an external web endpoint, which receives requests from the Order application. Each successful request results in a Kubernetes Job. Once the job finishes, it will send back a request to the application component in Order. The request from Order to ExtProd, and the request from ExtProd back to Order are not directly related, and essentially represent two different transactions. If you need a component to put on a remote cluster, ExtProd is a good choice for this. You can tune the internal behavior of this component with the following Terraform variables.

| Variable               | Default | Effect                                                                |
|------------------------|---------|-----------------------------------------------------------------------|
| extprod_name           | gateway | Name of ExtProd - changes how it will show up in UIs like AppDynamics |
| extprod_replicas       | 2       | Copies of the Pod                                                     |
| extprod_cpu_request    | 100m    | CPU Request for each Pod                                              |
| extprod_cpu_limit      | 400m    | CPU Limit for each Pod                                                |
| extprod_memory_request | 128Mi   | Memory Request for each Pod                                           |
| extprod_memory_limit   | 512Mi   | Memory Limit for each Pod                                             |
| extprod_min_delay      | 0       | Minimum average delay for a request in milliseconds                   |
| extprod_max_delay      | 1000    | Maximum average delay for a request in milliseconds                   |
| extprod_job_min_delay  | 240     | Duration of the Kubernetes Job created by ExtProd                     |
| extprod_job_max_delay  | 360     | Duration of the Kubernetes Job created by ExtProd                     |

## Component: Accounting
The Accounting application component represents Deployments that are created with the purpose of showing oversized or undersized Pods. These components do not have any connectivity between them or any requests coming in or going out. They are just statically set to a certain CPU and/or memory usage, which can then be analyzed using monitoring tools like AppDynamics or Intersight Workload Optimizer. The Pods defined in this component are all defined dynamically through a variable called "accounting_clusterload_configurations". Changing this variable allows you to rename the Pods, to create new Pods, and to change their characteristics.

## Component: Procurement
