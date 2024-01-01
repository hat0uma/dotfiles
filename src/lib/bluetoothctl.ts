import $ from "https://deno.land/x/dax@0.35.0/mod.ts";

interface BluetoothDevice {
  Name?: string;
  Alias?: string;
  Appearance?: number;
  Icon?: string;
  Paired?: boolean;
  Bonded?: boolean;
  Trusted?: boolean;
  Blocked?: boolean;
  Connected?: boolean;
  LegacyPairing?: boolean;
  Modalias?: string;
  BatteryPercentage?: number;
}

// ❯ bluetoothctl info
// Device EE:EE:EE:EE:EE:EE (random)
//         Name: HHKB-Hybrid_1
//         Alias: HHKB-Hybrid_1
//         Appearance: 0x03c1 (961)
//         Icon: input-keyboard
//         Paired: yes
//         Bonded: yes
//         Trusted: no
//         Blocked: no
//         Connected: yes
//         LegacyPairing: no
//         UUID: Generic Access Profile    (00000000-0000-0000-0000-000000000000)
//         UUID: Generic Attribute Profile (00000000-0000-0000-0000-000000000000)
//         UUID: Device Information        (00000000-0000-0000-0000-000000000000)
//         UUID: Battery Service           (00000000-0000-0000-8000-000000000000)
//         UUID: Human Interface Device    (00000000-0000-0000-0000-000000000000)
//         Modalias: usb:v000E0E0EEE
//         Battery Percentage: 0x64 (100)

// ❯ bluetoothctl info
// Missing device address argument
// DeviceSet (null) not available

export async function info() {
  const lines = await $`bluetoothctl info`.lines();
  const parsed: BluetoothDevice[] = [];

  for (const line of lines) {
    if (line.startsWith("Device")) {
      parsed.push({});
      continue;
    }
    const current = parsed[parsed.length - 1];
    if (!current) {
      console.error(`output is not started with "Device": ${lines}`);
      continue;
    }

    const match = line.match(/\s*(?<key>[^:]+): (?<value>.*)/);
    if (!match || !match.groups || !match.groups.key || !match.groups.value) {
      console.error(`Failed to parse line: ${line}`);
      continue;
    }
    const { key, value } = match.groups;
    switch (key) {
      case "Name":
      case "Alias":
      case "Icon":
      case "Modalias":
        current[key] = value;
        break;
      case "Appearance":
      case "Battery Percentage":
        current["BatteryPercentage"] = parseInt(value);
        break;
      case "Paired":
      case "Bonded":
      case "Trusted":
      case "Blocked":
      case "Connected":
      case "LegacyPairing":
        current[key] = value === "yes";
        break;
      default:
        break;
    }
  }
  return parsed;
}
