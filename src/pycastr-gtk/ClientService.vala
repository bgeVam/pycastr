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

using Gee;

class ClientService
{

    private bool searching = false;
    private bool include_screen = false;
    private Client active_client;
    private ArrayList<Client> newly_discovered_clients = new ArrayList<Client>();
    private ArrayList<Client> available_clients = new ArrayList<Client>();
    private PycastrIndicator pycastr_indicator;

    public bool get_include_screen()
    {
        return include_screen;
    }

    public void set_include_screen(bool include_screen)
    {
        this.include_screen = include_screen;
    }

    public bool is_searching()
    {
        return searching;
    }

    public void set_pycastr_indicator(PycastrIndicator pycastr_indicator)
    {
        this.pycastr_indicator = pycastr_indicator;
    }

    public ArrayList<Client> get_available_clients()
    {
        return available_clients;
    }

    public void search_available_clients()
    {
        searching = true;
        string[] spawn_args = {"python3", "pycastr.py", "list-clients"};
        string[] spawn_env = Environ.get ();
        Pid child_pid;
        int standard_input;
        int standard_output;
        int standard_error;
        Process.spawn_async_with_pipes ("/opt/pycastr/src/",
                                        spawn_args,
                                        spawn_env,
                                        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                                        null,
                                        out child_pid,
                                        out standard_input,
                                        out standard_output,
                                        out standard_error);

        //Process the available clients on stdout:
        IOChannel output = new IOChannel.unix_new (standard_output);
        output.add_watch (IOCondition.IN | IOCondition.HUP, (channel, condition) =>
        {
            return process_line (channel, condition, "stdout");
        });
        ChildWatch.add (child_pid, (pid, status) =>
        {
            Process.close_pid (pid);
            //Update list of available clients
            if(active_client != null)
            {
                newly_discovered_clients.add(active_client);
            }
            available_clients = newly_discovered_clients;
            newly_discovered_clients = new ArrayList<Client>();
            pycastr_indicator.update();
            searching = false;
        });
    }

    private bool process_line (IOChannel channel, IOCondition condition, string stream_name)
    {
        if (condition == IOCondition.HUP)
        {
            return false;
        }
        try
        {
            string client_line;
            channel.read_line (out client_line, null, null);
            string[] client_name_ip_array = client_line.split_set(":");
            if ((active_client == null) || (client_name_ip_array[1] != active_client.get_ip()))
            {
                newly_discovered_clients.add (new Client(client_name_ip_array[0], client_name_ip_array[1]));
            }
        }
        catch (IOChannelError e)
        {
            stderr.printf ("%s: IOChannelError: %s\n", stream_name, e.message);
            return false;
        }
        catch (ConvertError e)
        {
            stderr.printf ("%s: ConvertError: %s\n", stream_name, e.message);
            return false;
        }
        return true;
    }

    public void cast_start(Client client)
    {
        if ((active_client != null) && (active_client.get_ip() != client.get_ip()))
        {
            cast_stop(active_client);
        }
        client.set_active(true);
        active_client = client;
        pycastr_indicator.update();
        string[] spawn_args = {"python3", "pycastr.py", "cast-start", "-C" + client.get_ip(), (include_screen) ? null : "--audio-only"};
        string[] spawn_env = Environ.get ();
        Pid child_pid;
        Process.spawn_async ("/opt/pycastr/src/",
                             spawn_args,
                             spawn_env,
                             SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                             null,
                             out child_pid);
        ChildWatch.add (child_pid, (pid, status) =>
        {
            Process.close_pid (pid);
        });
    }

    public void cast_stop(Client client)
    {
        client.set_active(false);
        active_client = null;
        pycastr_indicator.update();
        string[] spawn_args = {"python3", "pycastr.py", "cast-stop"};
        string[] spawn_env = Environ.get ();
        Pid child_pid;
        Process.spawn_async ("/opt/pycastr/src/",
                             spawn_args,
                             spawn_env,
                             SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD,
                             null,
                             out child_pid);
        ChildWatch.add (child_pid, (pid, status) =>
        {
            Process.close_pid (pid);
        });
    }
}