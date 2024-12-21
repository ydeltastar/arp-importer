@tool
extends EditorPlugin


var arp_importer = EditorScenePostImportPluginARP.new()


func _enter_tree() -> void:
	add_scene_post_import_plugin(arp_importer)


func _exit_tree() -> void:
	remove_scene_post_import_plugin(arp_importer)
