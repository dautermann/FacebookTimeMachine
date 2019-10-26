# FacebookTimeMachine
Use a time machine to meet Nobel laureates!

## Getting started
Type in coordinates (e.g. 37.3318, -122.0312) and you'll see a city appear in the table. Click on the city name and start traveling!

You can also type in a place name and it'll auto complete and populate the initial city table.  Any places that appear do have coordinates associated with them.  To do proper city name autocomplete, I would have to bring in G00gle API's which I wasn't in the mood to do.

As you travel through time, watch your fuel level drop.

## Time analysis
I recompute the cost to get to all 400+ Nobel winners from the time machine's current position each time the time machine jumps (and the table view... errr... dashboard updates).  So the cost is N entries, or linear.

## Things I wish I could've done (but couldn't do because real life / job got in the way)

1. I do a lot of `willSet` and `didSet` in my production code when setting properties.  I didn't find an opportunity to do it in these initial vesions.

2. display nobel prize details even better

3. color the cells (green, red, yellow/orange for "dangerous" travel) to indicate whether we have enough fuel to travel

4. implement a real fuel gage (like a progress bar?)

5. bring in MapKit for reals!
