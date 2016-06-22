# mixt-greens-bot

Input: CSV of Mixt Greens orders

Output: Orders Mixt Greens delivery

## setup

- ruby 2.3.1
- selenium chromedriver (brew install `chromedriver`)

## csv format

Make a Google Form. It should export a CSV that looks like this:
```
Timestamp,Username,Name,What kind of thing?,What menu item?,Customize your item?
6/21/2016 10:04:13,joanna@initech.com,Joanna,Salad,Be Well,Medium dressing
6/21/2016 10:05:10,peter@initech.com,Peter Gibbons,Salad,Cowboy,Heavy on the dressing :)
```
- Field names don't matter.
- Timestamp, Username, and Customize are ignored.

## usage
1. Create a `.env` file and specify ADDRESS1, ADDRESS2, CITY and ZIP
2. Go [to the site](https://mixtgreens.brinkpos.net/order/) and find the store URL you want. Specify it as STORE_URL.
3. `rescue start.rb ~/Downloads/Form\ Responses\ 1.csv 6/22/2016`
4. It will stop when it gets stuck, then you get to manually enter in the orders.
5. Enter payment manually.

## notes

- BUG: Doesn't do order customization
- TIP: Make sure the "What menu item?" is enumerable. Don't trust user input ;)
- License: MIT
