// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013 Pantheon Developers (http://launchpad.net/online-accounts-plug)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Corentin Noël <tintou@mailoo.org>
 */
namespace OnlineAccounts {

    string dialog_bus_address;
    
    public Plugins.Manager plugins_manager;
    public AccountsManager accounts_manager;
    
    public class Plug : Pantheon.Switchboard.Plug {
        
        Gtk.Grid grid;
        AccountView account_view;
        
        public Plug () {
            plug_name = _("Online Accounts");
            plugins_manager = new Plugins.Manager (Build.PLUGIN_DIR, "online-accounts", null);
            accounts_manager = new AccountsManager ();
            
            var main_grid = new Gtk.Grid ();
            var paned = new Granite.Widgets.ThinPaned ();
            var source_selector = new SourceSelector ();
            source_selector.account_selected.connect (account_selected);
            grid = new Gtk.Grid ();
            grid.expand = true;
            
            paned.pack1 (source_selector, false, false);
            paned.pack2 (grid, true, false);
            paned.set_position (200);
            
            main_grid.attach (paned, 0, 0, 1, 1);
            main_grid.show_all ();
            this.add (main_grid);
            
            check_folder ();
            plugins_manager.activate ();
            plugins_manager.load_accounts ();
            
        }
        
        public void on_exit () {
            warning ("do real destruction here");
            base.on_exit ();
        }
        
        private void check_folder () {
            try {
                File directory = File.new_for_path (GLib.Environment.get_user_config_dir () + "/gsignond/");
                if (!directory.query_exists ()) {
                    directory.make_directory_with_parents ();
                }
                File file = File.new_for_path (GLib.Environment.get_user_config_dir () + "/gsignond/gsignond.conf");
                if (!file.query_exists ()) {
                    debug ("creating gsignond config file");
                    var iostream = file.create_readwrite (GLib.FileCreateFlags.NONE);
                    iostream.output_stream.write (config_file.data);
                    iostream.close ();
                }
            } catch (Error e) {
                stdout.printf ("Error: %s\n", e.message);
            }
        }
        
        private void account_selected (OnlineAccounts.Plugin plugin) {
            if (account_view != null) {
                account_view.hide ();
            }
            account_view = new AccountView (plugin);
            grid.attach (account_view, 0, 0, 1, 1);
            account_view.show_all ();
        }

    }
    
    public static string string_from_string_array (string[] strv, string separator = " ") {
        string output = "";
        bool first = true;
        foreach (var str in strv) {
            if (first) {
                output = str;
                first = false;
            } else {
                output = output + separator + str;
            }
        }
        return output;
    }
}
public static int main (string[] args) {

    Gtk.init (ref args);
    var plug = new OnlineAccounts.Plug ();
    plug.register (plug.plug_name);
    plug.show_all ();
    Gtk.main ();
    return 0;
}

const string config_file = """[General]
Extension = pantheon
[ObjectTimeouts]
IdentityTimeout = 5
AuthSessionTimeout = 5""";
