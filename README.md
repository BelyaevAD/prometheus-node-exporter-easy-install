Universal Installer for Prometheus and Node Exporter
====================================================

**Script Name:** `install_prometheus_node_exporter.sh`

Description
-----------

This script installs and configures Prometheus and Node Exporter on a Linux system. It allows you to specify custom ports and usernames during installation, adds firewall rules if a supported firewall is detected, and outputs the final addresses to access Prometheus and Node Exporter.

Features
--------

*   **Custom Ports and Usernames:** Specify custom ports and usernames for Prometheus and Node Exporter during installation.
*   **Firewall Configuration:** Automatically adds firewall rules for the specified ports if `ufw` or `firewall-cmd` is detected.
*   **Service Management:** Creates `systemd` service files for Prometheus and Node Exporter for easy management.
*   **Configuration Update:** Automatically updates Prometheus configuration to include Node Exporter as a target.
*   **Cleanup:** Removes installation files after setup to save space.
*   **Information Output:** Displays the URLs where Prometheus and Node Exporter can be accessed.

How to Use
----------

You can run this script directly using `wget` or `curl`:

**Using `wget`:**

```bash
bash <(wget -qO- https://raw.githubusercontent.com/BelyaevAD/prometheus-node-exporter-easy-install/main/install_prometheus_node_exporter.sh)
```

**Using `curl`:**

```bash
bash <(curl -s https://raw.githubusercontent.com/BelyaevAD/prometheus-node-exporter-easy-install/main/install_prometheus_node_exporter.sh)
```

**Alternatively, you can clone the repository and run the script:**

```
git clone https://github.com/BelyaevAD/prometheus-node-exporter-easy-install.git cd prometheus-node-exporter-easy-install bash install_prometheus_node_exporter.sh
```

### Installation Steps

1.  **Run the Script:**
    
    Execute the script using one of the methods above. You may need to run it with `sudo` if you are not logged in as root.
    
2.  **Follow the Prompts:**
    
    *   **Enter port for Prometheus \[9090\]:** Press `Enter` to accept the default port `9090` or enter a custom port.
    *   **Enter username for Prometheus \[prometheus\]:** Press `Enter` to accept the default username `prometheus` or enter a custom username.
    *   **Enter port for Node Exporter \[9100\]:** Press `Enter` to accept the default port `9100` or enter a custom port.
    *   **Enter username for Node Exporter \[node\_exporter\]:** Press `Enter` to accept the default username `node_exporter` or enter a custom username.
3.  **Wait for Installation to Complete:**
    
    The script will:
    
    *   Detect your OS (supports Ubuntu, Debian, CentOS, and RHEL).
    *   Install necessary dependencies (`wget`, `tar`).
    *   Perform pre-installation checks (like port availability).
    *   Install Prometheus and Node Exporter.
    *   Configure firewall rules.
    *   Clean up installation files.
    *   Output the final URLs to access Prometheus and Node Exporter.
4.  **Access Prometheus and Node Exporter:**
    
    *   Prometheus: `http://<your-server-ip>:<prometheus-port>`
    *   Node Exporter Metrics: `http://<your-server-ip>:<node-exporter-port>/metrics`

Notes
-----

### System Requirements

*   Linux system with `systemd`.
*   Internet connection to download packages.
*   Root permissions (you may need to run the script with `sudo`).

### Firewall Configuration

*   The script checks for `ufw` or `firewall-cmd`.
*   If neither is found, it skips firewall configuration.
*   Ensure that your firewall settings allow incoming connections on the specified ports.

### Updating Versions

*   Check for the latest versions of Prometheus and Node Exporter:
    *   [Prometheus Releases](https://github.com/prometheus/prometheus/releases)
    *   [Node Exporter Releases](https://github.com/prometheus/node_exporter/releases)
*   Update the `PROM_VERSION` and `NODE_VERSION` variables in the script if newer versions are available.

### Uninstallation

To uninstall Prometheus and Node Exporter installed by this script, run:

```bash
bash install_prometheus_node_exporter.sh uninstall
```

### Security Considerations

*   **Review the Script:** Always review scripts before running them, especially if sourced from the internet.
*   **Trusted Source:** Ensure that the script is hosted in a trusted repository.
*   **Permissions:** Running scripts with `sudo` can be risky. Make sure you understand what the script does.

### Compatibility

*   **Supported Operating Systems:**
    *   Ubuntu
    *   Debian
    *   CentOS
    *   RHEL
*   **Unsupported Systems:**
    *   Other Linux distributions may not be fully supported.
    *   The script checks for system compatibility and will exit if the OS is not supported.

License
-------

This script is released under the [MIT License](https://opensource.org/licenses/MIT).

Disclaimer
----------

Use this script at your own risk. The author is not responsible for any damage caused by running this script.

* * *

By following this guide, you can easily set up Prometheus and Node Exporter on your Linux system for monitoring purposes. The script simplifies the installation process and gets you up and running quickly.
