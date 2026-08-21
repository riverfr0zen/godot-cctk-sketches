class_name Utils
extends RefCounted

static func reset_defaults(obj, ignore : Array[String] = []):
    for prop in obj.get_property_list():
        if prop["name"] in ignore: continue
        if prop["usage"] & PROPERTY_USAGE_EDITOR and prop["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var default_val = obj.get_script().get_property_default_value(prop["name"])
            obj.set(prop["name"], default_val)
            #print("%s: %s" % [prop["name"], default_val])
