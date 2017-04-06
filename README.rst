*************
theater-setup
*************

.. image:: figures/theater_setup.png
   :align: center

.. contents:: `Table Of Contents`
    :depth: 3

Intro
-----

A set of simple scripts, config files, data and instructions
for transforming a Linux PC (possibly with a TV) into
a clickable environment for playing videos.

A configuration is recommended to experienced ``UNIX`` users only.

.. image:: figures/screenshot_1_small.png
   :height: 200px
   :target: figures/screenshot_1.png

Features
========
* easy to use for a common computer users
* clickable redirecting of sound output between a computer and a TV
* clickable turning of TV connection on/off
* automatic subtitle loading
* manageable using remote controller

Typical use case
================
You have a ``Linux``-based computer connected to a TV and you need
to setup a simple environment that can be used by people without
an IT background.

These common users may then redirect a video output to the TV screen
by mouse clicking only and use a remote controller/keypad to control it from a distance.

Description
-----------

Scripts
=======
* tv [start|stop] -- turn a HDMI-connected tv on/off by using xrandr
* speaker [pc|tv] -- switch sound output between a PC and a TV speakers
* submplay VIDEO_FILE -- wrapper for mplayer with automatic subtitle lookout
* controller [start|stop] -- turn a bluetooth controller on/off


movewin
#######
The script ``movewin`` moves application windows across your screen.

.. code:: bash

  # move all mplayer instances to a monitor on the right
  movewin --window mplayer --monitor ":RIGHT:"
  # move the currently active window 200 pixels to the right and 10% up
  movewin --window ":ACTIVE:" --shift "200x-10%"

For more info invoke :code:`movewin --help`.

Icons
=====
* icons are to be put on user's desktop to allow clickable management of tv, speakers and remote controller

Remote controller support
=========================

There are several types of remote controllers:
  * keypads -- easy to setup and low cost
  * bluetooth controllers -- you may need to buy a USB bluetooth dongle, not easy to setup
  * IR controllers

The `Bluetooth controller installation steps`_ section describes how to connect a
`PS3 navigation controller <http://us.playstation.com/ps3/accessories/playstation-move-navigation-controller-ps3.html>`_
that is supported since the 4.2 version of the Linux kernel (released in January 2012).

The `Numeric keypad installation steps`_ section describes how to connect wireless numeric keypad
`EVOLVEO WN160 <http://www.evolveo.eu/en/WN160>`_.


Installation
------------

Dependencies
============

* xrandr
* mplayer
* pulseaudio
* glib2 (optional, to enable configuration using GSettings)

Bluetooth remote controller dependencies
########################################
* expect
* zenity
* antimicro (software for managing mappings of your remote controller)
* bluez (bluetooth stack), bluez-utils
* pygobject (python bindings for GObject library)
* xdotool

Numeric keypad dependencies
###########################
* pygobject (python bindings for GObject library)
* xdotool


Tree structure
==============

This tree shows where the distributed files should end up.

.. code:: bash

  ├── home 
      └── $USER
          └── .mplayer
              ├── config
              └── input.conf
          └── Desktop
              ├── speaker-tv.desktop
              ├── speaker-pc.desktop
              ├── tv-start.desktop
              └── tv-stop.desktop
  ├── usr
      └── local
          └── bin
              ├── tv
              ├── speaker
              ├── submplay
              ├── [controller]
              └── [winmove]
          └── etc
              └── [antimicro_controller.amgp]
      └── share
          └── icons
              └── hicolor
                  └── {16x16,32x32,48x48,64x64,96x96,128x128,192x192,256x256,512x512}
                      ├── theater-setup-speaker-pc.png
                      ├── theater-setup-speaker-tv.png
                      ├── theater-setup-tv-start.png
                      ├── theater-setup-tv-stop.png
                      ├── [theater-setup-controller-start.png]
                      └── [theater-setup-controller-stop.png]
          └── glib-2.0
              └── schemas
                  ├── [com.github.svlc.theater-setup.gschema.xml]
                  └── [com.github.svlc.theater-setup.gschema.override]

Installation steps
==================

Configure settings
##################

The project uses `GSettings <https://developer.gnome.org/GSettings/>`_ to manage all settings.

As a first step, see the ``gsettings/com.github.svlc.theater-setup.gschema.xml`` file for a detailed description
of all configuration keys. Then edit the values of these keys in the ``gsettings/com.github.svlc.theater-setup.gschema.override`` file.

This table describes all ``gsettings`` keys:

.. list-table::

   + * **key name in GSettings schema**
     * **used by script**
     * **comment**
   + * tv-start-xrandr-options
     * tv
     *
   + * tv-stop-xrandr-options
     * tv
     *
   + * pulseaudio-primary-sink
     * speaker
     *
   + * pulseaudio-secondary-sink
     * speaker
     *
   + * bluetooth-adapter-mac-address
     * controller
     * Set only if you intend to use a bluetooth controller.
   + * bluetooth-controller-mac-address
     * controller
     * Set only if you intend to use a bluetooth controller.

After the whole installation process is finished, you can change any of these keys by using ``gsettings`` command
or by a widely-used graphical program ``dconf-editor``.

.. code:: bash

  $ gsettings get com.github.svlc.theater-setup bluetooth-controller-mac-address
  @ms '00:00:00:00:00:00'

  # notice the double quotes
  $ gsettings set com.github.svlc.theater-setup bluetooth-controller-mac-address "'00:07:04:EF:38:C3'"

Install
#######

* there is no single ``make install`` rule because the installation
  is too machine-specific
* paths are relative to the project's root directory
* make sure you backup a relevant files so that nothing gets overwritten

.. code:: bash

  # install the essential scripts, a default path is ``/usr/local/bin``
  $ make install-scripts # invoke under root

.. code:: bash

  # install mplayer configuration file (possibly backing the existing config up)
  $ install -b --suffix=".old" -D -m 644 mplayer/{config,input.conf} "$HOME"/.mplayer/

.. code:: bash

  # optionally install the desktop entries to the Desktop
  $ install -m 744 shortcuts/{speaker-pc,speaker-tv,tv-start,tv-stop}.desktop "$HOME"/Desktop

.. code:: bash

  # optionally install the icons for the desktop entries
  # invoke under root
  $ for dir in "16x16" "32x32" "48x48" "64x64" "96x96" "128x128" "192x192" "256x256" "512x512"; do \
      install -D -m 644 icons/${dir}/theater-setup-{speaker-pc,speaker-tv,tv-stop,tv-start}.png "/usr/share/icons/hicolor/${dir}/apps/"; \
    done;

  # update icon cache if some of desktop entries are missing icons
  # invoke under root
  $ gtk-update-icon-cache -f /usr/share/icons/hicolor/

.. code:: bash

   # under root
   # install GSettings schema and schema override file
   $ install -m 644 gsettings/{com.github.svlc.theater-setup.gschema.xml,com.github.svlc.theater-setup.gschema.override} /usr/share/glib-2.0/schemas

   # under root
   # compile all schemas into binary file
   $ glib-compile-schemas /usr/share/glib-2.0/schemas

Configure mplayer settings
##########################
Modify ``~/.mplayer/config`` and ``~/.mplayer/input.conf`` configuration files
according to your needs.

Tweak display manager
#####################
It is often convenient to have a TV connection turned off
before login and after logout. This can be done by adding
these commands into a corresponding pre-login and logout scripts.

.. code:: bash

  tv stop
  speaker pc

In case of ``GDM`` (``GNOME Display Manager``) these are the ``/etc/gdm/Init/Default``
and the ``/etc/gdm/PostSession/Default`` files.

Associate
#########
Associate some video extensions (avi, ogv, mp4, ...) with the ``submplay`` script.

Play
####
Prepare some video files with a corresponding subtitles and test a setup environment.

Bluetooth controller installation steps
=======================================

This section describes how to configure the ``PS3 navigation controller``, but the process should be similar to all bluetooth controllers.

Install all dependencies
########################

Install all dependencies described in the `Bluetooth remote controller dependencies`_ section.

Setup a trusted bluetooth connection
####################################

1. First check that your bluetooth adapter is properly recognized by the kernel.

.. code:: bash

   $ dmesg
   ...
   [140908.745952] usb 6-2: new full-speed USB device number 21 using uhci_hcd
   [140908.939021] Bluetooth: hci1: BCM: chip id 63
   [140908.971042] Bluetooth: hci1: BCM20702A
   [140908.973038] Bluetooth: hci1: BCM20702A1 (001.002.014) build 0000
   [140909.592077] Bluetooth: hci1: BCM20702A1 (001.002.014) build 1467
   [140909.624076] Bluetooth: hci1: Broadcom Bluetooth Device
   ...

2. Then I highly recommend you to ensure hardware-level disablement of all bluetooth adapters that you won't need during a connection process.

   The reason is simple -- the ``bluetoothctl`` command is poorly writen and is capable of associating
   your remote controller with an unwanted bluetooth adapter. Even when the adapter is powered-off,
   disabled at the software level and unselected in the bluetoothctl session.

   To make sure that just one bluetooth adapter is present and unblocked, run:

.. code:: bash

   rfkill list bluetooth

3. Then, start and enable a bluetooth daemon (in this case systemd service manager is used):

.. code:: bash

   systemctl enable --now bluetooth.service

4. Invoke a ``bluetoothctl`` command and power the adapter on:

.. code:: bash

   $ bluetoothctl
   [NEW] Controller 5C:F3:70:6C:2E:8B system [default]
   [bluetooth]# show 5C:F3:70:6C:2E:8B
   Controller 5C:F3:70:6C:2E:8B
         Name: system
         Alias: system
         Class: 0x000000
         Powered: no
         Discoverable: no
         Pairable: yes
         UUID: Generic Attribute Profile (00001801-0000-1000-8000-00805f9b34fb)
         UUID: A/V Remote Control        (0000110e-0000-1000-8000-00805f9b34fb)
         UUID: PnP Information           (00001200-0000-1000-8000-00805f9b34fb)
         UUID: Generic Access Profile    (00001800-0000-1000-8000-00805f9b34fb)
         UUID: A/V Remote Control Target (0000110c-0000-1000-8000-00805f9b34fb)
         Modalias: usb:v1D6Bp0246d052C
         Discovering: no
   [bluetooth]# power on
   [CHG] Controller 5C:F3:70:6C:2E:8B Class: 0x00010c
   Changing power on succeeded
   [CHG] Controller 5C:F3:70:6C:2E:8B Powered: yes

5. Now connect the ``PS3 navigation controller`` via a USB cable for a few seconds until the new device shows up.

.. code:: bash

   [NEW] Device 00:07:04:EF:38:C3 Navigation Controller

6. Then unplug the USB cable and insert these two commands:

.. code:: bash

   [bluetooth]# agent on
   Agent registered
   [bluetooth]# default-agent
   Default agent request successful

7. Now push the navigation controller's PS button and wait. An authorization request should appear. Authorize it and make a trust:

.. code:: bash

    [CHG] Device 00:07:04:EF:38:C3 Class: 0x000508
    [CHG] Device 00:07:04:EF:38:C3 Icon: input-gaming
    [CHG] Device 00:07:04:EF:38:C3 Connected: yes
    [CHG] Device 00:07:04:EF:38:C3 Modalias: usb:v054Cp0268d0100
    [CHG] Device 00:07:04:EF:38:C3 UUIDs: 00001124-0000-1000-8000-00805f9b34fb
    [CHG] Device 00:07:04:EF:38:C3 UUIDs: 00001200-0000-1000-8000-00805f9b34fb
    [CHG] Device 00:07:04:EF:38:C3 ServicesResolved: yes
    Authorize service
    [agent] Authorize service 00001124-0000-1000-8000-00805f9b34fb (yes/no): yes
    [Navigation Controller]# info 00:07:04:EF:38:C3
    Device 00:07:04:EF:38:C3
          Name: Navigation Controller
          Alias: Navigation Controller
          Class: 0x000508
          Icon: input-gaming
          Paired: no
          Trusted: no
          Blocked: no
          Connected: yes
          LegacyPairing: no
          UUID: Human Interface Device... (00001124-0000-1000-8000-00805f9b34fb)
          UUID: PnP Information           (00001200-0000-1000-8000-00805f9b34fb)
          Modalias: usb:v054Cp0268d0100
    [Navigation Controller]# trust 00:07:04:EF:38:C3
    [CHG] Device 00:07:04:EF:38:C3 Trusted: yes
    Changing 00:07:04:EF:38:C3 trust succeeded

8. Finally, disconnect the controller and exit:

.. code:: bash

   [Navigation Controller]# disconnect 00:07:04:EF:38:C3
   Attempting to disconnect from 00:07:04:EF:38:C3
   [CHG] Device 00:07:04:EF:38:C3 ServicesResolved: no
   Successful disconnected
   [CHG] Device 00:07:04:EF:38:C3 Connected: no
   [bluetooth]# exit
   [DEL] Controller 5C:F3:70:6C:2E:8B system [default]

Now you can test if the ``controller`` script (located in ``scripts/`` directory) works flawlessly.

Note
~~~~

If some problem occurs during the ``bluetoothctl`` setup, just remove the controller and start all over again:

.. code:: bash

   [bluetooth]# remove 00:07:04:EF:38:C3
   Device has been removed
   [DEL] Device 00:07:04:EF:38:C3 Navigation Controller

Install
#######

.. code:: bash

   # invoke under root
   install -D -m 755 scripts/{controller,movewin} /usr/local/bin/

.. code:: bash

   # optionally install the desktop entries to the Desktop
   $ install -m 744 shortcuts/{controller-start,controller-stop}.desktop "$HOME"/Desktop

.. code:: bash

   # optionally install the icons for the desktop entries
   # invoke under root
   $ for dir in "16x16" "32x32" "48x48" "64x64" "96x96" "128x128" "192x192" "256x256" "512x512"; do \
       install -D -m 644 icons/${dir}/theater-setup-{controller-start,controller-stop}.png "/usr/share/icons/hicolor/${dir}/apps/"; \
     done;

   # update icon cache if some of desktop entries are missing icons
   # invoke under root
   $ gtk-update-icon-cache -f /usr/share/icons/hicolor/

.. code:: bash

   $ install -D -m 644 antimicro/antimicro_controller.amgp /usr/local/etc/

Configure
#########

Configure the ``/usr/local/etc/antimicro_controller.amgp`` antimicro config using the ``antimicro`` program.

   The predefined setup looks like this:

   .. image:: figures/ps3_navigation_controller.png

   .. list-table::

      + * **button**
        * **action**
        * **keyboard mapping**
        * **comment**
      + * up/down
        * volume up/down
        * up/down
        *
      + * left/right
        * seek backward/forward
        * left/right
        *
      + * × button
        * toggle fullscreen mode
        * 'f'
        *
      + * ◎ button
        * show elapsed time and total duration
        * 'P'
        *
      + * PS button
        * unchanged
        *
        * turn the controller on, turn the controller off (if pressed for 10+ secs)
      + * L1 button
        * pause
        * space
        *
      + * L2 button
        * pause
        * space
        *
      + * stick left
        * move active window to the monitor on the left
        * none
        * invokes :code:`movewin --window ":ACTIVE:" --monitor ":LEFT:"`
      + * stick right
        * move active window to the monitor on the right
        * none
        * invokes :code:`movewin --window ":ACTIVE:" --monitor ":RIGHT:"`
      + * stick up
        * none
        *
        *
      + * stick down
        * none
        *
        *
      + * L3 button
        * move active window to the next monitor
        * none
        * invokes :code:`movewin --window ":ACTIVE:" --monitor ":NEXT:"`



Numeric keypad installation steps
=================================

This section describes how to configure the wireless numeric keypad ``EVOLVEO WN160``, but the process should be very similar to all numeric keypads.

Install all dependencies
########################

Install all dependencies described in the `Numeric keypad dependencies`_ section.

Install
#######

.. code:: bash

   # invoke under root
   install -D -m 755 scripts/movewin /usr/local/bin/

Configure
#########

You can change some key bindings for your keypad by editing the ``~/mplayer/input.conf`` file.

The predefined setup looks like this:

.. image:: figures/evolveo_wn160.png


TODO
----
* create a wallpaper(s) with instructions and ``mplayer`` shortcuts on it
* create a printable sheet with shortcuts

License
-------
GPLv3

Authors
-------
* S\. Vlcek <svlc at inventati.org>
