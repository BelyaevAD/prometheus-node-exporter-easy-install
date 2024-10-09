#!/bin/bash

# Universal Installer for Prometheus and Node Exporter
# Author: [Your Name]

# Default values
PROMETHEUS_PORT=9090
NODE_EXPORTER_PORT=9100

# Get custom ports from the user
read -p "Enter port for Prometheus [default: $PROMETHEUS_PORT]: " input
if [ ! -z "$input" ]; then
  PROMETHEUS_PORT=$input
fi

read -p "Enter port for Node Exporter [default: $NODE_EXPORTER_PORT]: " input
if [ ! -z "$input" ]; then
  NODE_EXPORTER_PORT=$input
fi

# Function to add firewall rules
add_firewall_rule() {
  PORT=$1
  if command -v ufw &> /dev/null; then
    sudo ufw allow $PORT
  elif command -v firewall-cmd &> /dev/null; then
    sudo firewall-cmd --permanent --add-port=${PORT}/tcp
    sudo firewall-cmd --reload
  else
    echo "No supported firewall found. Skipping firewall configuration."
  fi
}

# Install Prometheus
install_prometheus() {
  echo "Installing Prometheus..."
  wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
  tar xvf prometheus-2.45.0.linux-amd64.tar.gz
  sudo mv prometheus-2.45.0.linux-amd64 /usr/local/prometheus
  sudo useradd --no-create-home --shell /bin/false prometheus
  sudo mkdir /etc/prometheus
  sudo mkdir /var/lib/prometheus
  sudo cp /usr/local/prometheus/prometheus.yml /etc/prometheus/
  sudo chown -R prometheus:prometheus /usr/local/prometheus /etc/prometheus /var/lib/prometheus

  # Update Prometheus configuration with custom port
  sudo sed -i "s/^  - job_name: 'prometheus'$/  - job_name: 'prometheus'\n    static_configs:\n    - targets: ['localhost:${PROMETHEUS_PORT}']/" /etc/prometheus/prometheus.yml

  # Create systemd service for Prometheus
  sudo bash -c "cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/prometheus/prometheus \\
  --config.file=/etc/prometheus/prometheus.yml \\
  --web.listen-address=0.0.0.0:${PROMETHEUS_PORT}

[Install]
WantedBy=multi-user.target
EOF"

  sudo systemctl daemon-reload
  sudo systemctl start prometheus
  sudo systemctl enable prometheus
}

# Install Node Exporter
install_node_exporter() {
  echo "Installing Node Exporter..."
  wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
  tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
  sudo mv node_exporter-1.6.1.linux-amd64 /usr/local/node_exporter
  sudo useradd --no-create-home --shell /bin/false node_exporter
  sudo chown -R node_exporter:node_exporter /usr/local/node_exporter

  # Create systemd service for Node Exporter
  sudo bash -c "cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/node_exporter/node_exporter \\
  --web.listen-address=0.0.0.0:${NODE_EXPORTER_PORT}

[Install]
WantedBy=multi-user.target
EOF"

  sudo systemctl daemon-reload
  sudo systemctl start node_exporter
  sudo systemctl enable node_exporter

  # Add Node Exporter to Prometheus configuration
  sudo bash -c "cat <<EOF >> /etc/prometheus/prometheus.yml

  - job_name: 'node_exporter'
    static_configs:
    - targets: ['localhost:${NODE_EXPORTER_PORT}']
EOF"

  sudo systemctl restart prometheus
}

# Add firewall rules
add_firewall_rule $PROMETHEUS_PORT
add_firewall_rule $NODE_EXPORTER_PORT

# Install Prometheus and Node Exporter
install_prometheus
install_node_exporter

# Output final addresses for Grafana
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Installation complete!"
echo "Add the following addresses to Grafana:"
echo "Prometheus: http://${IP_ADDRESS}:${PROMETHEUS_PORT}"
echo "Node Exporter: http://${IP_ADDRESS}:${NODE_EXPORTER_PORT}"
