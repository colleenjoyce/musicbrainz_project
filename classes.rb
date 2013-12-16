require 'httparty'
require 'musicbrainz'
require 'json'

MusicBrainz.configure do |c|
  # Application identity (required)
  c.app_name = "My Music App"
  c.app_version = "1.0"
  c.contact = "support@mymusicapp.com"

  # Cache config (optional)
  c.cache_path = "/tmp/musicbrainz-cache"
  c.perform_caching = true

  # Querying config (optional)
  c.query_interval = 1.2 # seconds
  c.tries_limit = 2
end

class Artist
  attr_reader :id, :name, :discography
  #string, array of class album

  def initialize(id, name, discography)
    @id = id
    @name = name
    @discography = discography
  end

  def to_s
    @name
  end
end

class Album
  attr_reader :id, :name, :release_date, :tracks
  attr_accessor :art_url
  #string, string, date, hash of tracks, string
  
  def initialize(id, name, release_date, tracks, art_url)
    @id = id
    @name = name
    @release_date = release_date
    @tracks = tracks
    @art_url = art_url
  end
  
  def to_s
    @name
  end
end

def album_art_check(id)
  album_art = ""
  begin
    album_art_hash = JSON(HTTParty::get("http://coverartarchive.org/release/#{id}"))
    album_art_hash["images"].each{
      |image|
  if image["front"]
    album_art = image["thumbnails"]["small"]
  end
  if album_art != ""
  break
  end
    }
  rescue
    album_art = ""
  end
  album_art
end

def artist(name)
  musicbrainz_artist = MusicBrainz::Artist.find_by_name(name)
  artist_albums = []
  album_dup_check = [] 
  artist = ""

if musicbrainz_artist
  musicbrainz_artist.release_groups.each{
    |release_group|
    release_group.releases.each{
      |album|
      if album.type == "Album" && album.status == "Official" && album.format = "CD"
      if album_dup_check.include?(album.title)
        artist_albums.each{|a_album|
      if  a_album.name == album.title && a_album.art_url == ""
        a_album.art_url = album_art_check(album.id)
      end
      }
      else
      tracks = {}
      album.tracks.each{
      |track|
      tracks[track.position] = track.title
      }
      album_art = album_art_check(album.id)
      artist_albums.push(Album.new(album.id, album.title, album.date, tracks, album_art))
      album_dup_check.push(album.title)
      end
      end
    }
  }
  artist = Artist.new(musicbrainz_artist.id, name, artist_albums)
end
artist
end