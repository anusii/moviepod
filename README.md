# Movie Star Personal Data Wallet

A personal movies (and TV series) database and recommender.

## Use Cases

### Personal Movie Data Store

As a user I can

- [ ] Enter movies I have watched
- [ ] Retrieve movie details from imdb or movielens
  - [ ] Artwork
  - [ ] Release date
  - [ ] Other meta data as available
- [ ] Have them stored in my POD encrypted
- [ ] Retrieved from my POD on startup and displayed on my HOME
- [ ] Associate a review with a movie (text)
- [ ] Associate a rating with a movie (0-5)
- [ ] Movies are presented in the GUI using movie art work
- [ ] Movies can be sorted by
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
