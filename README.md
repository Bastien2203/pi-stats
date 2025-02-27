# pi-stats
A simple script to display system stats for your Raspberry Pi, including CPU temperature, memory usage, disk usage, CPU load, and power status.

<img width="569" alt="Capture d’écran 2025-02-27 à 10 34 29" src="https://github.com/user-attachments/assets/08f47fbc-b614-49c4-9e7d-f070a2e5ce3e" />


## Installation

1. Clone or download the script:
```sh
curl -o ~/.metrics.sh https://raw.githubusercontent.com/Bastien2203/pi-stats/metrics.sh
```

1. Make it executable:
```sh
chmod +x ~/.metrics.sh
```

## Usage

To display system metrics, run:
```sh
~/.metrics.sh
```

## Auto-run on Terminal Start

To automatically show the metrics when opening a new terminal:

- **For Bash:**
```sh
echo 'source ~/.metrics.sh' >> ~/.bashrc
```

- **For Zsh:**
```sh
echo 'source ~/.metrics.sh' >> ~/.zshrc
```

Then, restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc`).

---------------

> 💡 Feedback and suggestions are always welcome!
