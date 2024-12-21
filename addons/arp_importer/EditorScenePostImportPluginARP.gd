@tool
class_name EditorScenePostImportPluginARP extends EditorScenePostImportPlugin
## Move baked root motion from the root Node to a Root bone so it works better
## with Godot's animation system since it wants bones as root motion.
##
## Best options:[br]
## 	Auto Rig Pro options:
## 		Godot Preset, Humanoid, Disable export Root Bone (c_traj), Enable Root Motion[br][br], Enable Rename for Godot.
## 	Advanced Import Settings:[br]
##		Enabled "Arp Skeleton".
## 1 frame root bone delay issue:
## "You probably have a dependency loop. Open a console window and look for "dependency cycle" warnings. Fix them."


## Option to enable processing for Auto Rig Pro files.
func _get_import_options(path: String) -> void:
	add_import_option_advanced(TYPE_BOOL, "arp_skeleton", false, PROPERTY_HINT_NONE, "Fix root bone from Auto-rig Pro")


func _pre_process(scene: Node) -> void:
	var is_arp = get_option_value("arp_skeleton")
	if not is_arp:
		return

	modify_skeleton(scene)
	modify_animation(scene)


func modify_skeleton(scene:Node):
	var skeleton = find_skeleton(scene)

	# Can't set a new bone as parent of previous bones
	# Need to rebuild whole skeleton so root is the first bone
	var bones = []
	for idx in skeleton.get_bone_count():
		var bone = {
			name = skeleton.get_bone_name(idx),
			enabled = skeleton.is_bone_enabled(idx),
			parent = skeleton.get_bone_parent(idx),
			pose = skeleton.get_bone_pose(idx),
			rest = skeleton.get_bone_rest(idx),
			pos = skeleton.get_bone_pose_position(idx),
			rot = skeleton.get_bone_pose_rotation(idx),
			scale = skeleton.get_bone_pose_scale(idx)
		}
		bones.append(bone)

	skeleton.clear_bones()

	skeleton.add_bone("Root")

	# Make all bones child of the Root bone
	for idx in bones.size():
		var bone = bones[idx]

		if bone.name == "Root":
			continue

		skeleton.add_bone(bone.name)
		var new_idx = skeleton.get_bone_count()-1

		skeleton.set_bone_enabled(new_idx, bone.enabled)
		skeleton.set_bone_rest(new_idx, bone.rest)
		skeleton.set_bone_pose_position(new_idx, bone.pos)
		skeleton.set_bone_pose_rotation(new_idx, bone.rot)
		skeleton.set_bone_pose_scale(new_idx, bone.scale)
		skeleton.set_bone_parent(new_idx, bone.parent+1)

	for idx in skeleton.get_parentless_bones():
		if idx != 0:
			skeleton.set_bone_parent(idx, 0)

	for idx in skeleton.get_bone_count():
		skeleton.force_update_bone_child_transform(idx)


func modify_animation(scene:Node):
	# Find the skeleton
	var skeleton = find_skeleton(scene)
	var animation_player:AnimationPlayer = scene.find_child("AnimationPlayer")

	var skeleton_path = scene.get_path_to(skeleton, false)
	#print(skeleton_path)

	if animation_player:
		for animation_name in animation_player.get_animation_list():
			var animation:Animation = animation_player.get_animation(animation_name)
			var path = "root"
			var new_path = "%s:Root" % skeleton_path
			change_name(animation, path, new_path, Animation.TYPE_POSITION_3D)
			change_name(animation, path, new_path, Animation.TYPE_ROTATION_3D)
			change_name(animation, path, new_path, Animation.TYPE_SCALE_3D)

	var root:Node3D = scene.find_child("root") as Node3D
	root.transform = Transform3D()


func change_name(animation:Animation, path, new_path, type:Animation.TrackType):
	var root_track = animation.find_track(path, type)
	if root_track == -1:
		return

	var bone_track = animation.find_track(new_path, type)
	if bone_track > -1:
		animation.remove_track(bone_track)

	animation.track_set_path(root_track, new_path)
	animation.track_move_to(root_track, 0)


func find_skeleton(scene:Node) -> Skeleton3D:
	var skeleton:Skeleton3D
	for child in scene.get_child(0).get_children():
		if child is Skeleton3D:
			skeleton = child
			break

	return skeleton


func _get_type_name(type:Animation.TrackType):
	match type:
		Animation.TYPE_POSITION_3D:
			return "TYPE_POSITION_3D"
		Animation.TYPE_ROTATION_3D:
			return "TYPE_ROTATION_3D"
		Animation.TYPE_SCALE_3D:
			return "TYPE_SCALE_3D"


func analysis(scene:Node):
	print_children(scene)

	var animation_player:AnimationPlayer = scene.find_child("AnimationPlayer")
	for animation_name in animation_player.get_animation_list():
		var animation:Animation = animation_player.get_animation(animation_name)
		for i in animation.get_track_count():
			print(animation.track_get_path(i))

	var skeleton = find_skeleton(scene)
	print(skeleton.name)
	print(skeleton.unique_name_in_owner)


func print_children(node):
	print(node)
	for child in node.get_children():
		print_children(child)
