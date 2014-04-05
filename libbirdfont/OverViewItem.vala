/*
    Copyright (C) 2012, 2014 Johan Mattsson

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
	
public class OverViewItem : GLib.Object {
	public unichar character = 'A'; // FIXME: 
	public GlyphCollection? glyphs;
	public double x;
	public double y;
	public bool selected = false;
	public CharacterInfo info;
	
	public static double DEFAULT_WIDTH = 100;
	public static double DEFAULT_HEIGHT = 130;
	public static double DEFAULT_MARGIN = 20;
	
	public static double width = 100;
	public static double height = 130;
	public static double margin = 20;
	
	public OverViewItem (GlyphCollection? glyphs, unichar character, double x, double y) {	
		this.x = x;
		this.y = y;
		this.character = character;
		this.glyphs = glyphs;
		this.info = new CharacterInfo (character);
	}
	
	public static double full_width () {
		return width + margin;
	}

	public static double full_height () {
		return height + margin;
	}
	
	public bool click (uint button, double px, double py) {
		bool a;
		GlyphCollection g;
		selected = (x <= px <= x + width) && (y <= py <= y + height);
		
		if (has_icons () && glyphs != null) {
			g = (!) glyphs;
			a = g.get_version_list ().menu_item_action (px, py); // select one item on the menu
			if (a) {
				return selected;
			}
			
			g.get_version_list ().menu_icon_action (px, py); // click in the open menu
		}
		
		if (has_icons () && info.is_over_icon (px, py)) {
			MainWindow.get_overview ().set_character_info (info);
		}
				
		return selected;
	}

	public void double_click (uint button, double px, double py) {
		selected = (x <= px <= x + width) && (y <= py <= y + height);
		
		if (selected) {
			edit_glyph ();
		}
	}
	
	public void edit_glyph () {
		OverView overview = MainWindow.get_overview ();
		
		if (glyphs == null) {
			overview.open_new_glyph_signal (character);
		} else {
			overview.open_glyph_signal ((!) glyphs);
			((!) glyphs).get_current ().close_path ();
		}		
	}
	
	public void draw (Context cr) {
		cr.save ();
		cr.set_source_rgba (1, 1, 1, 1);
		cr.rectangle (x, y, width, height);
		cr.fill ();
		cr.restore ();
		
		cr.save ();
		cr.set_source_rgba (0, 0, 0, 1);
		cr.rectangle (x, y, width, height);
		cr.set_line_width (0.5);
		cr.stroke ();
		cr.restore ();
		
		draw_thumbnail (cr, glyphs, x, y + height); 	
		draw_caption (cr);	
	}

	private bool draw_thumbnail (Context cr, GlyphCollection? gl, double x, double y) {
		Glyph g;
		Font font;
		double gx, gy;
		double x1, x2, y1, y2;
		double scale;
		double scale_box;
		double w, h;
		double glyph_width, glyph_height;
		Surface s;
		Context c;
		
		if (gl != null) {
			font = BirdFont.get_current_font ();
			w = width;
			h = height;
			
			scale_box = (width / DEFAULT_WIDTH);
					
			g = ((!) gl).get_current ();
			g.boundaries (out x1, out y1, out x2, out y2);
		
			glyph_width = x2 - x1;
			glyph_height = y2 - y1;
			
			// caption height is 20
			scale = (h - 20) / (font.top_limit - font.bottom_limit);
			
			gx = ((w / scale) - glyph_width) / 2;
			gy = (h / scale) - 25 / scale;
			
			s = new Surface.similar (cr.get_target (), Content.COLOR_ALPHA, (int) w, (int) h - 20);
			c = new Context (s);
			
			c.save ();
			c.scale (scale, scale);	

			g.add_help_lines ();
			
			c.translate (gx - g.get_lsb () - Glyph.xc (), g.get_baseline () + gy - Glyph.yc ());
			
			g.draw_paths (c);
			c.restore ();

			cr.save ();
			cr.set_source_surface (s, x, y - h);
			cr.paint ();
			cr.restore ();
		}
		
		return (gl != null);
	}

	public bool has_icons () {
		return width > 50;
	}

	public void draw_caption (Context cr) {
		StringBuilder name = new StringBuilder ();
		name.append_unichar (character);
		
		cr.save ();
		
		if (selected) {
			cr.set_source_rgba (50/255.0, 50/255.0, 50/255.0, 1);
		} else {
			cr.set_source_rgba (100/255.0, 100/255.0, 100/255.0, 1);			
		}
		
		cr.rectangle (x + 1, y + height - 20, width - 2, 20 - 1);
		cr.fill ();
		
		if (has_icons ()) {
			draw_menu (cr);
			draw_character_info_icon (cr);
		}
		
		cr.restore ();
		
		cr.save ();
		cr.set_font_size (14);
		
		if (selected) {
			cr.set_source_rgba (1, 1, 1, 1);
		} else {
			cr.set_source_rgba (0, 0, 0, 1);
		}
		
		cr.move_to (x + 0.08 * width, y + height - 6);
		
		if (glyphs == null) {
			cr.show_text (name.str);
		} else {
			cr.show_text (((!)glyphs).get_current ().name);
		}
		
		cr.restore ();
	}

	private void draw_character_info_icon (Context cr) {
		double px = x + width - 17;
		double py = y + height - 16;
		info.set_position (px, py);
		info.draw_icon (cr);
	}
	
	private void draw_menu (Context cr) {
		GlyphCollection g;
		DropMenu menu;
		
		if (glyphs == null) {
			return;
		}
		
		g = (!) glyphs;
		
		menu = g.get_version_list ();
		menu.set_position (x + width - 32, y + height - 16);
		menu.draw_icon (cr);
		menu.draw_menu (cr);
	}
}

}
