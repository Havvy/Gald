Gald
============

This project has known vulnerabilities. Don't use it in a production environment.

Of course, this code is not actually licensed to you, so using it in production
is already a bad idea. Projects on GitHub are not immediately free to use,
they also need a permissive license which this project does not have. That said,
feel free to look around and learn.

This project has been abandoned.

What is This?
=============

This project is a game, in the same vein as [Board Game Online](https://boardgameonline.com/),
where players get together to advance forward towards a goal line.

The differences that I want to achieve here:

1. Not sexual. BGO has options for having sex.
2. More fair. BGO has effects that vary wildly. Some grant you invincibility while
other just outright kill you.
3. Battles. Let players do combat against NPCs. Battles should be short though.
This also means having health - though that's also for fairness.
4. More exploration. The length of an overall turn should be greater than BGO, but
with more options to explore. Have areas randomly found that can be re-explored
at the player's convenience, not just based on luck.
5. Avoid gimmicks. No half-baked 'reference-mode', memes that go stale, and whatnot.
Or when they are added, always able to be disabled.

The Umbrella
============

Gald is split into two main applications: Gald and GaldWeb. The former is the
core of the game while the latter is the website itself. Not having to worry
about the website or JSON while working on the game makes it easier to work on.
It also means that there could e.g. be GaldIrc or some other way of playing. Though
there should also be GaldPool or something that holds GaldWeb.RaceManager if that
happens.
