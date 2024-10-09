#!/bin/bash

# Script for installing Prometheus and Node Exporter
# Supported OS: Ubuntu and CentOS

# Set versions of Prometheus and Node Exporter
PROM_VERSION="2.47.0"
NODE_VERSION="1.6.1"

set -e

# Function to detect the distribution
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "Failed to determine the operating system."
        exit 1
    fi
}

# Function to check if a port is in use
check_port() {
    if ss -tuln | grep -q ":$1 "; then
        return 1
    else
        return 0
    fi
}

# Function to install dependencies
install_dependencies() {
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        apt-get update
        apt-get install -y wget tar
    elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
        yum install -y wget tar
    else
        echo "Distribution not supported."
        exit 1
    fi
}

# Function to add firewall rules
configure_firewall() {
    if command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --permanent --add-port=$1/tcp
        firewall-cmd --reload
    elif command -v ufw >/dev/null 2>&1; then
        ufw allow $1/tcp
    else
        echo "Firewall not detected or not supported."
    fi
}

# Function to install Prometheus
install_prometheus() {
    # Check if the user already exists
    if id "$PROM_USER" >/dev/null 2>&1; then
        echo "User $PROM_USER already exists."
    else
        useradd --no-create-home --shell /bin/false $PROM_USER
    fi

    # Create directory if it does not exist
    mkdir -p /etc/prometheus
    mkdir -p /var/lib/prometheus

    # Download and install Prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v$PROM_VERSION/prometheus-$PROM_VERSION.linux-amd64.tar.gz
    tar xvf prometheus-$PROM_VERSION.linux-amd64.tar.gz

    # Copy files to /etc/prometheus directory
    cp -r prometheus-$PROM_VERSION.linux-amd64/* /etc/prometheus/

    # Set permissions
    chown -R $PROM_USER:$PROM_USER /etc/prometheus
    chown -R $PROM_USER:$PROM_USER /var/lib/prometheus

    # Create system service
    cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus

[Service]
User=$PROM_USER
WorkingDirectory=/var/lib/prometheus
ExecStart=/etc/prometheus/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.listen-address=:$PROM_PORT

[Install]
WantedBy=multi-user.target
EOF

    # Start the service
    systemctl daemon-reload
    systemctl enable prometheus
    systemctl start prometheus
}

# Function to update Prometheus configuration
update_prometheus_config() {
    CONFIG_FILE="/etc/prometheus/prometheus.yml"

    # Check if configuration for node_exporter already exists
    if grep -q "job_name: 'node_exporter'" $CONFIG_FILE; then
        echo "Configuration for node_exporter already exists in prometheus.yml."
    else
        echo "Adding configuration for node_exporter to prometheus.yml."

        # Add configuration for node_exporter
        cat <<EOF >> $CONFIG_FILE

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:$NODE_PORT']
EOF
    fi
    
    systemctl restart prometheus
}

# Function to install Node Exporter
install_node_exporter() {
    # Check if the user already exists
    if id "$NODE_USER" >/dev/null 2>&1; then
        echo "User $NODE_USER already exists."
    else
        useradd --no-create-home --shell /bin/false $NODE_USER
    fi

    # Create directory if it does not exist
    mkdir -p /etc/node_exporter

    # Download and install Node Exporter
    wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_VERSION/node_exporter-$NODE_VERSION.linux-amd64.tar.gz
    tar xvf node_exporter-$NODE_VERSION.linux-amd64.tar.gz

    # Copy files to /etc/node_exporter directory
    cp -r node_exporter-$NODE_VERSION.linux-amd64/* /etc/node_exporter/

    # Set permissions
    chown -R $NODE_USER:$NODE_USER /etc/node_exporter

    # Create system service
    cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter

[Service]
User=$NODE_USER
ExecStart=/etc/node_exporter/node_exporter --web.listen-address=:$NODE_PORT

[Install]
WantedBy=multi-user.target
EOF

    # Start the service
    systemctl daemon-reload
    systemctl enable node_exporter
    systemctl start node_exporter
}

# Function to remove installation files
cleanup() {
    rm -f prometheus-$PROM_VERSION.linux-amd64.tar.gz
    rm -f node_exporter-$NODE_VERSION.linux-amd64.tar.gz
    rm -rf prometheus-$PROM_VERSION.linux-amd64
    rm -rf node_exporter-$NODE_VERSION.linux-amd64
}

# Function to check if ports are in use
pre_install_checks() {
    if check_port $PROM_PORT; then
        echo "Port $PROM_PORT is available."
    else
        echo "Port $PROM_PORT is already in use."
        exit 1
    fi

    if check_port $NODE_PORT; then
        echo "Port $NODE_PORT is available."
    else
        echo "Port $NODE_PORT is already in use."
        exit 1
    fi
}

# Function to display final address
output_info() {
    IP=$(hostname -I | awk '{print $1}')
    echo "Prometheus is available at: http://$IP:$PROM_PORT"
    echo "Node Exporter is available at: http://$IP:$NODE_PORT/metrics"
}

# Function for uninstallation
uninstall() {
    systemctl stop prometheus node_exporter
    systemctl disable prometheus node_exporter
    rm -f /etc/systemd/system/prometheus.service
    rm -f /etc/systemd/system/node_exporter.service
    userdel $PROM_USER
    userdel $NODE_USER
    rm -rf /etc/prometheus
    rm -rf /etc/node_exporter
    rm -rf /var/lib/prometheus
    echo "Prometheus and Node Exporter have been removed."
}

# Command-line parameter handling
ACTION=$1

if [ "$ACTION" = "install" ] || [ -z "$ACTION" ]; then
    # Prompt for ports and usernames
    read -p "Enter port for Prometheus [9090]: " PROM_PORT
    PROM_PORT=${PROM_PORT:-9090}

    read -p "Enter username for Prometheus [prometheus]: " PROM_USER
    PROM_USER=${PROM_USER:-prometheus}

    read -p "Enter port for Node Exporter [9100]: " NODE_PORT
    NODE_PORT=${NODE_PORT:-9100}

    read -p "Enter username for Node Exporter [node_exporter]: " NODE_USER
    NODE_USER=${NODE_USER:-node_exporter}

    # Detect OS
    detect_os

    # Perform pre-install checks
    pre_install_checks

    # Install dependencies
    install_dependencies

    # Install Node Exporter
    install_node_exporter

    # Install Prometheus
    install_prometheus

    # Update Prometheus configuration
    update_prometheus_config

    # Add firewall rules
    configure_firewall $PROM_PORT
    configure_firewall $NODE_PORT

    # Cleanup installation files
    cleanup

    # Display final information
    output_info

elif [ "$ACTION" = "uninstall" ]; then
    # Perform uninstallation
    uninstall
    exit 0
else
    echo "Unsupported action: $ACTION"
    echo "Usage: $0 [install|uninstall]"
    exit 1
fi
