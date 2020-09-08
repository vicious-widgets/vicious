Security Notes
==============

At the moment only one widget type (Gmail) requires
authentication information in order to get to the data.
In the future there could be more, and you should give some thought
to the issue of protecting your data.  The Gmail widget type by default
stores login information in the ``~/.netrc`` file, and you are advised
to make sure that file is only readable by the owner.  Other than that
we can not force all users to conform to one standard,
one way of keeping it secure, like in some keyring.

First let's clear why we simply don't encrypt the login information
and store it in ciphertext.  By exposing the algorithm anyone can
reverse the encryption steps.  Some claim even that's better than
plaintext but it's just security through obscurity.

Here are some ideas actually worth your time.  Users that have KDE
(or parts of it) installed could store their login information into
the Kwallet service and request it via DBus from the widget type.
It can be done with tools like ``dbus-send`` and ``qdbus``.
The Gnome keyring should support the same, so those with parts of Gnome
installed could use that keyring.

Users of GnuPG (and its agent) could consider encrypting the netrc file
with their GPG key.  Through the GPG Passphrase Agent they could then
decrypt the file transparently while their session is active.
