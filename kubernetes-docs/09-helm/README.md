# What is HELM



Commands
# Add repository first
helm repo add bitnami https://charts.bitnami.com/bitnami

# List the added repo
helm repo list

# Remove the added repo
helm repo remove repo_name


# List the available charts from the above repository
helm search repo bitnami

# List the available charts from the global not only from the above added repo
helm search hub wordpress


# Install the Chart
helm install bitnami/mysql --generate-name

# Get the latest list of charts
helm repo update

# Get the information about running chart
helm show chart bitnami/mysql

helm show all bitnami/mysql

helm list
NAME            	NAMESPACE	REVISION	UPDATED                             	STATUS  	CHART      	APP VERSION
mysql-1612624192	default  	1       	2021-02-06 16:09:56.283059 +0100 CET	deployed	mysql-8.3.0	8.0.23

# Get the status
helm status release_name like mysql-1612624192

# Uninstall a Release
helm uninstall mysql-1612624192

# Install the Chart with different values
helm install -f values.yaml bitnami/nginx --generat-name

# Upgrade to new version
helm upgrade -f values.yaml release_name repo_name/chart_name
helm upgrade -f values.yaml mysql-1612624192 bitnami/mysql

# check history of any release
helm history mysql-1612624192

# Rollback
helm rollback [RELEASE] [REVISION]
helm rollback mysql-1612624192 2

# DOwnload the chart files to make changes/review
helm pull repo_name/chart_name
helm pull bitnami/nginx

# Create your own chart
helm create deis-workflow

# Package the chart created by you
helm package deis-workflow

# Install above create chart
helm install deis-workflow ./deis-workflow-0.1.0.tgz