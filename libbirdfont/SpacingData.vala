/*
    Copyright (C) 2014 Johan Mattsson

    This library is free software; you can redistribute it and/or modify 
    it under the terms of the GNU Lesser General Public License as 
    published by the Free Software Foundation; either version 3 of the 
    License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful, but 
    WITHOUT ANY WARRANTY; without even the implied warranty of 
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
    Lesser General Public License for more details.
*/
using Cairo;
using Math;

namespace BirdFont {

public class SpacingData : GLib.Object {
	
	public KerningClasses kerning_classes;
	
	public Gee.ArrayList<SpacingClass> classes = new Gee.ArrayList<SpacingClass> ();
	Gee.ArrayList<String> connections = new Gee.ArrayList<String> ();

	public SpacingData (KerningClasses kerning) {
		kerning_classes = kerning;
	}

	public KerningClasses get_kerning_classes () {
		return kerning_classes;
	}

	public Gee.ArrayList<string> get_all_connections (string glyph) {
		String s;
		Gee.ArrayList<string> c = new Gee.ArrayList<string> ();
		
		connections.clear ();
		
		add_connections (glyph);
		
		foreach (String t in connections) {
			c.add (t.data.dup ());
		}
		
		connections.clear ();
		
		return c;
	}
	
	bool has_connection (string s) {
		foreach (String t in connections) {
			if (t.data == s) {
				return true;
			}
		}
		
		return false;
	}
	
	public void add_connections (string glyph) {
		String sb = new String (glyph);
		
		connections.add (sb);
		
		foreach (SpacingClass s in classes) {
			if (s.first == glyph) {
				if (has_connection (s.next)) {
					add_connections (s.next);
				}
			}

			if (s.next == glyph) {
				if (has_connection (s.first)) {
					add_connections (s.first);
				}
			}
		}
		
		connections.sort ((a, b) => {
			return strcmp ((string) a, (string) b);
		});
	}

	public void add_class (string first, string next) {
		SpacingClass s = new SpacingClass (first, next);
		s.updated.connect (update_all_rows);
		s.updated.connect (update_kerning);
		classes.add (s);
		update_kerning (s);
	}

	void update_all_rows (SpacingClass s) {
		MainWindow.get_spacing_class_tab ().update_rows ();
	}

	public void update_kerning (SpacingClass s) {
		Font font = kerning_classes.font;
		GlyphCollection? g;
		GlyphCollection gc;
		
		if (s.next != "?") {
			kerning_classes.update_space_class (s.next);
			g = font.get_glyph_collection (s.next);
			if (g != null) {
				gc = (!) g;
				gc.get_current ().update_spacing_class ();
			}
		}
		
		if (s.first != "?") {
			kerning_classes.update_space_class (s.first);
			g = font.get_glyph_collection (s.first);
			if (g != null) {
				gc = (!) g;
				gc.get_current ().update_spacing_class ();
			}
		}
		
		KerningTools.update_spacing_classes ();
	}
	
	class String : GLib.Object {
		
		public string data;
		
		public String (string s) {
			data = s.dup ();
		}	
	}
}

}