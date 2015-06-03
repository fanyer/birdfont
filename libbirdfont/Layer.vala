/*
    Copyright (C) 2015 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/

namespace BirdFont {

public class Layer : GLib.Object {
	public PathList paths;
	public Gee.ArrayList<Layer> subgroups;
	public bool visible = true;
	
	public Layer () {
		paths = new PathList ();
		subgroups = new Gee.ArrayList<Layer> ();
	}

	public PathList get_all_paths () {
		PathList p = new PathList ();
		
		p.append (paths);
		
		foreach (Layer sublayer in subgroups) {
			p.append (sublayer.get_all_paths ());
		}
		
		return p;
	}

	public PathList get_visible_paths () {
		PathList p = new PathList ();
		
		p.append (paths);
		
		foreach (Layer sublayer in subgroups) {
			if (sublayer.visible) {
				p.append (sublayer.get_all_paths ());
			}
		}
		
		return p;
	}
		
	public void add_layer (Layer layer) {
		subgroups.add (layer);
	}

	public void add_path (Path path) {
		paths.add (path);
	}

	public void remove_path (Path path) {
		paths.remove (path);
		foreach (Layer sublayer in subgroups) {
			sublayer.remove_path (path);
		}
	}

	public void remove_layer (Layer layer) {
		subgroups.remove (layer);
		foreach (Layer sublayer in subgroups) {
			sublayer.remove_layer (layer);
		}
	}
		
	public Layer copy () {
		Layer layer = new Layer ();
		
		layer.paths = paths.copy ();
		foreach (Layer l in subgroups) {
			layer.subgroups.add (l.copy ());
		}
		
		return layer;
	}
}

}
