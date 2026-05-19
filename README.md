# gravity_turn_KSP
A set of GNU Octave routines that produce a KOS-compatible database for flying a gravity turn in Kerbal Space Program.

Run get_launch_trajectory.m to run the main program. Should work out-of-the-box with example vehicle datafile provided.

To specify a new vehicle, create an Octave program formattted like toucan1a.m and change vehicle_datafile in get_launch_trajectory to the name of your new file. Set different target altitudes and pitchover settings in get_launch_trajectory.m.

This code is provided with limited quality assurance and documentation. I do not guarantee functionality, usability, or intelligibility on your machine. 
