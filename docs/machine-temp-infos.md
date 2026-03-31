# Machine temperature infos

## Laptop

```bash
temp.sh --cpu
CPU: 38.0°C
```

```bash
➜ sensors
coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +39.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +34.0°C  (high = +100.0°C, crit = +100.0°C)
Core 4:        +35.0°C  (high = +100.0°C, crit = +100.0°C)
Core 8:        +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 9:        +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 10:       +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 11:       +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 12:       +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 13:       +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 14:       +37.0°C  (high = +100.0°C, crit = +100.0°C)
Core 15:       +37.0°C  (high = +100.0°C, crit = +100.0°C)

ucsi_source_psy_USBC000:002-isa-0000
Adapter: ISA adapter
in0:           0.00 V  (min =  +0.00 V, max =  +0.00 V)
curr1:         0.00 A  (max =  +0.00 A)

nvme-pci-0100
Adapter: PCI adapter
Composite:    +22.9°C  (low  =  -0.1°C, high = +82.8°C)
                       (crit = +84.8°C)
Sensor 1:     +22.9°C  (low  = -273.1°C, high = +65261.8°C)

acpitz-acpi-0
Adapter: ACPI interface
temp1:        +38.0°C

iwlwifi_1-virtual-0
Adapter: Virtual device
temp1:        +29.0°C

thinkpad-isa-0000
Adapter: ISA adapter
fan1:           0 RPM
fan2:           0 RPM
CPU:          +38.0°C
GPU:          +27.0°C
temp3:        +24.0°C
temp4:        +35.0°C
temp5:         +0.0°C
temp6:         +0.0°C
temp7:         +0.0°C
temp8:            N/A

ucsi_source_psy_USBC000:001-isa-0000
Adapter: ISA adapter
in0:           0.00 V  (min =  +0.00 V, max =  +0.00 V)
curr1:         0.00 A  (max =  +0.00 A)

BAT0-acpi-0
Adapter: ACPI interface
in0:          10.90 V
power1:       13.35 W

acpi_fan-isa-0000
Adapter: ISA adapter
fan1:           0 RPM
```

## Desktop temperature info

```bash
./src/system/info/temp.sh --cpu --gpu --nvme
CPU: 42.2°C
GPU: 39°C
NVME: 28.9°C
```

```bash
sensors
nvme-pci-0100
Adapter: PCI adapter
Composite:    +28.9°C  (low  = -273.1°C, high = +84.8°C)
                       (crit = +84.8°C)
Sensor 1:     +28.9°C  (low  = -273.1°C, high = +65261.8°C)
Sensor 2:     +36.9°C  (low  = -273.1°C, high = +65261.8°C)

zenpower-pci-00c3
Adapter: PCI adapter
SVI2_Core:     1.32 V
SVI2_SoC:    994.00 mV
Tdie:         +39.8°C  (high = +95.0°C)
Tctl:         +39.8°C
Tccd1:        +43.8°C
SVI2_P_Core:  31.28 W
SVI2_P_SoC:    4.68 W
SVI2_C_Core:  23.06 A
SVI2_C_SoC:    4.71 A
```
