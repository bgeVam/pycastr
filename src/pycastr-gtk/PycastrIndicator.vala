/*
 * This file is part of Pycastr.
 * Pycastr is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Pycastr is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Copyright (c) 2017 bgeVam
 */

using Gtk;
using AppIndicator;
using Notify;
using Gee;
using GLib;

public class PycastrIndicator
{

    private Indicator indicator;
    private ClientService client_service;
    Gtk.MenuItem search_item = new Gtk.MenuItem();

    public PycastrIndicator()
    {
        this.client_service = new ClientService();
        this.indicator = new Indicator("Pycastr Indicator", "pycastr-status-off", IndicatorCategory.APPLICATION_STATUS);
        indicator.set_status(IndicatorStatus.ACTIVE);
        indicator.set_attention_icon_full("pycastr-status-on", "Standard Icon");
        indicator.set_menu(update_menu());
        client_service.set_pycastr_indicator(this);
        schedule_update_in(1);
    }

    public Indicator get_indicator()
    {
        return this.indicator;
    }

    public void update()
    {
        indicator.set_menu(update_menu());
    }

    public Gtk.Menu update_menu()
    {
        Gtk.Menu menu = new Gtk.Menu();
        search_item = get_search_menu_item();
        menu.append(search_item);
        foreach (Client client in client_service.get_available_clients())
        {
            if (client != null)
            {
                menu.add (get_client_menu_item(client));
            }
        }
        menu.append(get_include_screen_menu_item());
        menu.show_all();
        return menu;
    }

    private void schedule_update_in(int timeout)
    {
        GLib.Timeout.add_seconds(timeout, () =>
        {
            update_available_clients();
            schedule_update_in(300);
            return false;
        });
    }

    async void update_available_clients()
    {
        if (client_service.is_searching())
        {
            return;
        }
        client_service.search_available_clients();
        string search_string = "Searching";
        while(client_service.is_searching())
        {
            search_string += ".";
            if(search_string == ("Searching...."))
            {
                search_string = "Searching";
            }
            Thread.usleep(500 * 1000);
            search_item.set_label(search_string);
            Idle.add (update_available_clients.callback);
            yield;
        }
    }


    private Gtk.ImageMenuItem get_client_menu_item(Client client)
    {
        Gtk.Image image = new Gtk.Image ();
        image.set_from_icon_name("pycastr-status-off", Gtk.IconSize.SMALL_TOOLBAR );
        if (client.is_active())
        {
            image.set_from_icon_name("pycastr-status-on", Gtk.IconSize.SMALL_TOOLBAR );
        }
        Gtk.ImageMenuItem client_menu_item = new Gtk.ImageMenuItem.with_label(client.get_name());
        client_menu_item.set_image(image);
        client_menu_item.always_show_image = true;
        client_menu_item.activate.connect(() =>
        {
            if (client.is_active() == false)
            {
                indicator.set_status(IndicatorStatus.ATTENTION);
                notify_user("Now casting to " + client_menu_item.get_label());
                client_service.cast_start(client);
            }
            else
            {
                indicator.set_status(IndicatorStatus.ACTIVE);
                notify_user("Stop casting to " + client_menu_item.get_label());
                client_service.cast_stop(client);
            }
        });
        return client_menu_item;
    }

    private Gtk.MenuItem get_search_menu_item()
    {
        var search_menu_item = new Gtk.MenuItem.with_label("Search clients");
        search_menu_item.activate.connect(() =>
        {
            notify_user("Searching for clients");
            update_available_clients();
        });
        return search_menu_item;
    }

    private Gtk.CheckMenuItem get_include_screen_menu_item()
    {
        Gtk.CheckMenuItem screen_option = new Gtk.CheckMenuItem.with_label ("Screen mirroring");
        screen_option.set_active (client_service.get_include_screen());
        screen_option.toggled.connect (() =>
        {
            client_service.set_include_screen(screen_option.get_active());
        });
        return screen_option;
    }

    private void notify_user(string body)
    {
        Notify.init ("Initialization");
        var notification = new Notify.Notification("Pycastr", body, "pycastr-status-off");
        try
        {
            notification.show ();
        }
        catch (GLib.Error e)
        {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
