Helper addon to import rigs from Blender's Auto-Rig Pro in Godot.
It moves baked root motion from the root node to a `Root` bone so it works better with Godot's animation system and bone mapping since it doesn't like a node as the root for the animation.

### Usage
Copy `arp_importer` into your project's addons folder, enable the plugin, and check `Arp Skeleton` on your model importer options.

### Best ARP export options:
Use these options when exporting an Auto-Rig Pro rig from Blender:
- Godot Preset
- Humanoid
- Disable export Root Bone (c_traj)
- Enable Root Motion
- Enable Rename for Godot.