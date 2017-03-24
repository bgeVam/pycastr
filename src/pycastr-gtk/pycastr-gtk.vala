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
using GLib;

public class Pycastr
{

    public static int main(string[] args)
    {
        Gtk.init(ref args);
        PycastrIndicator pycastr_indicator = new PycastrIndicator();
        var indicator = pycastr_indicator.get_indicator();
        if (!(indicator is Indicator)) return -1;
        Gtk.main();
        return 0;
    }
}