# Universal Installer for Prometheus and Node Exporter

**Script Name:** `install_prometheus_node_exporter.sh`

## Description

This script installs and configures Prometheus and Node Exporter on a Linux system. It allows you to specify custom ports during installation, adds firewall rules if a supported firewall is detected, and outputs the final addresses to be added to Grafana.

## Features

- **Custom Ports:** Specify custom ports for Prometheus and Node Exporter during installation.
- **Firewall Configuration:** Automatically adds firewall rules for the specified ports if `ufw` or `firewall-cmd` is detected.
- **Grafana Integration:** Outputs the final URLs to be added to Grafana dashboards.

## How to Use

You can run this script directly using `wget` or `curl`:

**Using `wget`:**

```bash
bash <(wget -qO- https://raw.githubusercontent.com/BelyaevAD/prometheus-node-exporter-easy-install/main/install_prometheus_node_exporter.sh)
```


**Using `curl:`**

```bash
bash <(wget -qO- https://raw.githubusercontent.com/BelyaevAD/prometheus-node-exporter-easy-install/main/install_prometheus_node_exporter.sh)
```


## Notes

### System Requirements

- Linux system with `systemd`.
- Internet connection to download packages.
- Sufficient permissions (you may need to run the script with `sudo`).

### Firewall Configuration

- The script checks for `ufw` or `firewall-cmd`.
- If neither is found, it skips firewall configuration.

### Updating Versions

- Check for the latest versions of Prometheus and Node Exporter:
  - [Prometheus Releases](https://github.com/prometheus/prometheus/releases)
  - [Node Exporter Releases](https://github.com/prometheus/node_exporter/releases)
- Update the download URLs in the script if newer versions are available.

### Security Considerations

- Review the script before running it, especially if sourced from the internet.
- Ensure that the script is hosted in a trusted repository.

## License

This script is released under the [MIT License](https://opensource.org/licenses/MIT).

## Disclaimer

Use this script at your own risk. The author is not responsible for any damage caused by running this script.
