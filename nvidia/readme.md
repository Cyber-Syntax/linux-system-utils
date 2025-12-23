# nfancurve

> https://github.com/nan0s7/nfancurve

This shell script written from nan0s7 to handle nvidia fans auto via nvidia-settings.
I refactor the small things on codebase to fix my own problems.

## Basic setup

- Move config and temp.sh to `opt/nfancurve`

```bash
sudo mkdir -p /opt/nfancurve
mv config temp.sh /opt/nfancurve
```

- Make script executable

```bash
chmod +x /opt/nfancurve/temp.sh
```

- Add system service

```bash
sudo cp nfancurve.service /etc/systemd/system/
sudo systemctl enable nfancurve.service
```
