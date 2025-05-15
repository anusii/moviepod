# Movie Star Personal Data Wallet

A personal movies (and TV series) database and recommender.

## Use Cases

### Personal Movie Data Store

As a user I can

- [X] Retrieve movie details from imdb or movielens or **themoviedb** 
  - [X] Artwork
  - [X] Release date
  - [X] Description
  - [X] Rating
- [X] View all movies in the GUI using movie art work
- [ ] Settings to store my API key
- [ ] New lists with names that I choose (e.g., Watched and To Watch)
- [ ] Have any number of lists
- [ ] Add movies to my Watched list or my To Watch list
- [ ] Have the lists stored in my POD encrypted including the meta data
- [ ] Retrieved the two lists from my POD on startup
- [ ] Add my own comments to a movie (text)
- [ ] Add a rating with a movie (0-5?)
- [ ] My Movie Lists can be sorted by
  - [ ] name
  - [ ] rating
  - [ ] release date

### Sharing my Movies

As a user I can

- [ ] Share all my movies data with another user
- [ ] See who has shared their movies with me
- [ ] Switch to a view of another user's movies - perhaps on HOME
- [ ] Summarise movies across users
  - [ ] Frequency count
  - [ ] Total ratings count

### Recommending Movies

As a user I can

- [ ] Add private (not shared) views of other users sharing movies
  - [ ] Includes a weighting for each user (0-5, default 2)
- [ ] Add to summarise movies across users
   - [ ] Weighted ratings of movies - user rating * their movie rating

Add support for recommendation engine - review
https://github.com/recommenders-team/recommenders.
