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
class Client
{

    private bool active;
    private string name;
    private string ip;

    public Client(string name, string ip)
    {
        this.name = name;
        this.ip = ip;
        this.active = false;
    }

    public void set_active(bool active)
    {
        this.active = active;
    }

    public bool is_active()
    {
        return active;
    }

    public string get_ip()
    {
        return this.ip;
    }

    public string get_name()
    {
        return this.name;
    }
}