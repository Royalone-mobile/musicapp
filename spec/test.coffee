chai = require "chai"
expect = chai.expect
http = require 'http'
getFileByHTTP = (link, callback) ->
      http.get link, (res) =>
          res.setEncoding 'utf8'
          data = ''
          # callback res.headers.location
          if res.statusCode isnt 302
            res.on 'data', (chunk) =>
              data += chunk;
            res.on 'end', () =>
              
              callback data
          else callback(null)
        .on 'error', (e) =>
          console.log  "Cannot get file. ERROR: " + e.message
describe 'THE WEBSITE MP3.ZING.VN', ->
      Zing = require '../lib/zing'
      zing = new Zing()
      song = {}
      describe 'Song ID: ZW6ZC807', ->
            it 'should be encoded into 1382402055, has plays, topic and no author',(done) ->
                  zing.connect()
                  songid = 1382402055
                  link = "http://mp3.zing.vn/bai-hat/joke-link/#{zing._convertToId songid}.html"
                  getFileByHTTP link, (data)->
                        #console.log "anbinh"
                        zing._getFileByHTTP = ->
                        song = zing._processSong songid, data
                        # console.log song
                        expect(song.songid).to.equal("ZW6ZC807")
                        expect(parseInt(song.plays,10)).to.match(/\d+/)
                        expect(song.author).to.equal("")
                        expect(song.topic).to.equal('["Âu Mỹ","Pop","Audiophile"]')
                        done()
            it 'should be called Meditation, composed by Olivia Ong, created on 2013-04-07, has link and path',(done)->
                  zing.connect()
                  link = "http://m.mp3.zing.vn/xml/song/LnJGtLnNAQQxJQQyLDcyDHLG"
                  getFileByHTTP link, (data)->
                        data = JSON.parse data
                        song.song_name = data.data[0].title.trim()
                        song.song_artist = JSON.stringify data.data[0].performer.trim().split(',')
                        song.song_link = data.data[0].source

                        _str =  song.song_link.replace(/^.+load-song\//g,'').replace(/^.+song-load\//g,'')
                        testArr = []
                        testArr.push zing._decodeString _str.slice(i, i+4) for i in [0.._str.length-1] by 4
                        path =  decodeURIComponent testArr.join('').match(/.+mp3/g)

                        created = path.match(/^\d{4}\/\d{2}\/\d{2}/)?[0].replace(/\//g,"-")
                        song.path = path
                        song.created = created
                        expect(song.song_name).to.equal('Meditation')
                        expect(song.song_artist).to.equal('["Olivia Ong"]')
                        expect(song.song_link).to.equal('http://m.mp3.zing.vn/xml/song-load/MjAxMyUyRjA0JTJGMDclMkY3JTJGNCUyRjc0ZGQ3YWM4MzMyNTQxZDEwNjNhNTg4MGM5MWU1NGQxLm1wMyU3QzI=')
                        expect(song.path).to.equal('2013/04/07/7/4/74dd7ac8332541d1063a5880c91e54d1.mp3')
                        expect(song.created).to.equal('2013-04-07')
                        done()        
      describe "Album ID: ZWZAAIW0",->
            it 'should be called "Anh Muốn Quay Lại... Đến Khi Nào" and has certain properties', (done)->
                  zing.connect()
                  albumid = 1381671200
                  link = "http://mp3.zing.vn/album/joke-link/#{zing._convertToId albumid}.html"
                  getFileByHTTP link, (data)->
                        # console.log data
                        result = zing._processAlbum albumid, data
                        # console.log result
                        expect(result.albumid).to.equal("ZWZAAIW0")
                        expect(result.album_name).to.equal("Anh Muốn Quay Lại... Đến Khi Nào")
                        expect(result.album_artist).to.equal('["Khắc Việt"]')      
                        expect(result.topic).to.equal('["Việt Nam","Nhạc Trẻ"]') 
                        expect(parseInt(result.plays,10)).to.match(/\d+/)
                        expect(parseInt(result.released_year,10)).to.equal(2013)
                        expect(parseInt(result.nsongs,10)).to.equal(2)
                        expect(result.album_thumbnail).to.equal('http://image.mp3.zdn.vn/thumb/165_165/covers/5/2/5284f196b781e762b443f762a612172f_1365388107.jpg')
                        expect(result.description).to.equal('“Đến khi nào”. “Anh muốn quay lại” là nỗi nhớ người yêu da diết được Khắc Việt chuyển tải qua giai điệu sâu lắng từ đầu đến cuối. Đúng như tựa đề, “Anh muốn quay lại” như một đề nghị muộn màng khi tình cảm đã chia ly. Trong khi đó “Đến khi nào” lại là một tình yêu rộng lượng của người con trai sẵn sàng hy sinh để đem lại hạnh phúc cho người mình yêu. Việc sử dụng điệp từ “Đến khi nào” nhiều lần trong ca khúc cùng tên khiến cho người nghe đồng cảm nhiều hơn với tình yêu chung thủy của chàng trai trong ca khúc này. ')
                        expect(result.created).to.equal("2013-4-8 9:28:27")
                        done()
      describe "Video ID: ZWZ9ZO0U",->
            it 'should be called "Kiếp Phong Trần" by "Lâm Hùng" and has certain properties ', (done)->
                  zing.connect()
                  vid = 1381585668
                  link = "http://mp3.zing.vn/video-clip/joke-link/#{zing._convertToId vid}.html"
                  getFileByHTTP link, (data)->
                        video = zing._processVideo vid, data
                        # console.log video
                        expect(video.vid).to.equal(1381585668)
                        expect(video.title).to.equal('Kiếp Phong Trần')
                        expect(video.artists).to.equal('["Lâm Hùng"]')
                        expect(video.topic).to.equal('["Việt Nam","Nhạc Trẻ"]')
                        expect(parseInt(video.plays,10)).to.be.at.least(1014646)
                        expect(video.thumbnail).to.equal('http://image.mp3.zdn.vn/thumb/240_135/thumb_video/1/e/1ebf84dd6270b3978273b47f980c854a_1340685814.jpg')
                        expect(video.link).to.match(/http:\/\/mp3.zing.vn\/html5\/video\/[a-zA-Z0-9]{24}/)
                        expect(video.lyric).to.equal('Kiếp phong trần bạn đường sương gió, giang hồ phiêu lãng vũ trụ là nhà. Ánh trăng vàng làm đèn đêm thâu, tựa mình trên cát sương giăng làm màn. 2. Nắng chan hoà miền trời thanh câm tú, ngỡ ngàng tựa như bước trên bồng lai. Mong quên đời phàm trần còn nhiều trên vai, tranh giành như thế tốt hơn làm người. ĐK1: Đời nam nhi chí trai dọc ngang núi sông, dù gian khó quyết không nao núng lòng. Đường ta đi chông gai không làm nhụt chí hiên ngang, đường thênh thang bước chân vui miệt mài. ĐK2: Đàn réo rắt chất ngất bầu không gian sẽ xoa dịu ta quên nỗi đau thương trầm luân. Đàn hỡi có nói giúp cho lòng ta xin nhân gian thôi hận thù cho nét môi tươi rạng ngời. Ta vui cùng non bồng lãng du, ta vui cùng bạn đường gió sương. Trọn niềm vui xóa tan đau thương sầu kiếp.\t\t"')
                        expect(video.created).to.equal('2012-6-26')
                        done()
describe 'THE WEBSITE NHACSO.NET', ->
      Nhacso = require '../lib/nhacso'
      ns = new Nhacso()
      nsSong = {}
      album = {}
      video = {}
      encode = (id) ->
        arr = [id.slice(0,2),id.slice(2,3),id.slice(3,4),id.slice(4,6),id.slice(6,7),id.slice(7,8),id.slice(8,10)].filter (e) -> e if e isnt ''
        a = ['bw bg bQ bA aw ag aQ aA Zw Zg'.split(' '),
         'fedcbaZYXW'.split(''),
         'NJFBdZVRtp'.split(''),
         'U0 Uk UU UE V0 Vk VU VE W0 Wk'.split(' '),
         'RQTSVUXWZY'.split(''),
         'hlptx159BF'.split(''),
         ' X1 XF XV Wl W1 WF WV Vl V1'.split(' ')]
        parseInt(arr.map((v,i) -> a[6-i].indexOf(v)).join(''), 10)
      describe "Song ID: X1pZVkpYbg", ->
            it 'should be official, 320kbps, "Nhạc Trữ Tình", and has lyric',(done)->
                  encoded_id = "X1pZVkpYbg"
                  link = "http://nhacso.net/nghe-nhac/link-joke.#{encoded_id}==.html"
                  options = 
                        id : encode(encoded_id)
                        song : {}
                  getFileByHTTP link, (data)=>
                        # console.log "AHDFKJASHKDHASKJHDKSJA"
                        nsSong = ns.processSong data, options
                        expect(ns._decodeId(1285971)).to.equal("X1pZVkpYbg")
                        expect(nsSong.official).to.equal(1)
                        expect(nsSong.bitrate).to.equal(320)
                        expect(nsSong.plays).to.match(/\d+/)
                        expect(nsSong.topic).to.equal('Nhạc Trữ Tình')
                        expect(nsSong.islyric).to.equal(1)
                        expect(nsSong.lyric).to.equal("Em dấu yêu ơi anh đang quay về mười năm xa vắng\nanh đã đưa em, đưa em đi tìm một giấc mơ đời\nmười năm lạc loài phải không em\nmười năm hận thù trĩu trong tim\nta trót trao nhau thân, ta chót vong ân\nmang tuổi hoa niên, làm kiếp lưu đầy\nBóng tà ngả trên lưng đồi cỏ non\nGió hiền thoáng vi vu hàng lau xanh\nngoài kia là đồng thơm hương lúa mới\nbên lũy tre xanh ngả nghiêng hàng dừa\nvà đây là giòng sông ta thương mến,\nsoi bóng chung đôi những ngày ấu thơ\nAnh sẽ đưa em, đưa em xa rời vùng mây tăm tối\nAnh sẽ đưa em, đưa em đi về, về lối chân hiền\ncòn ai đợi chờ nữa không em\ncòn ai giận hờn nữa không em\nem hãy theo anh, men lối ăn năn\nta thoát cơn mê cùng giắt nhau về ")
                        done()
            it 'should be called "Vó Ngựa Trên Đồi Cỏ Non" and has certain properties',(done)->
                  id = 1285971
                  link = "http://nhacso.net/flash/song/xnl/1/id/" + ns._decodeId(id)
                  # console.log "Fetching from link #{link}"
                  options = 
                    id : id
                  getFileByHTTP link, (data)=>
                        ns.data = data
                        expect(ns.getValueXML(ns.data,"name",1)).to.equal("Vó Ngựa Trên Đồi Cỏ Non")
                        expect(ns.getValueXML(ns.data,"artist",0)).to.equal("Trường Vũ")
                        expect(parseInt(ns.getValueXML(ns.data,"artistlink",0).replace(/\.html/g,'').replace(/^.+-/g,''),10)).to.equal(2428)
                        expect(ns.getValueXML(ns.data,"author",0)).to.equal("Ngân Giang")
                        expect(parseInt(ns.getValueXML(ns.data, "authorlink",0).replace(/\.html/g,'').replace(/^.+-/g,''),10)).to.equal(963)
                        expect(parseInt(ns.data.match(/totalTime.+totalTime/)?[0].replace(/^.+>|<.+$/g,''),10)).to.equal(320)
                        expect(ns.getValueXML(ns.data, "mp3link", 0)).to.equal("http://st01.freesocialmusic.com/mp3/2013/05/10/1178050012/136817005912_7480.mp3")
                        ts = ns.getValueXML(ns.data, "mp3link", 0).match(/\/[0-9]+_/g)[0].replace(/\//, "").replace(/_/, "")
                        ts = parseInt(ts)*Math.pow(10,13-ts.length)
                        created = ns.formatDate new Date(ts)
                        expect(created).to.equal("2013-5-10 14:14:19")
                        done()
      describe "Album ID: WF5YUEVY",->
            it 'should be called "B-Sides And Other Things I Forgot" and has certain properties',(done)->
                  encoded_id = "WF5YUEVY"
                  link = "http://nhacso.net/nghe-album/ab.#{encoded_id}.html"
                  options = 
                        id : encode(encoded_id)
                  getFileByHTTP link, (data)=>
                        # disable callback function
                        ns._updateAlbum = ->
                        ns.getTotalSongsInAlbum = ->
                        ns.onAlbumFail = ->
                        album = ns.processAlbum data, options
                        # console.log album
                        expect(album.albumid).to.equal(669367)
                        expect(album.title).to.equal("B-Sides And Other Things I Forgot")
                        expect(album.artist).to.equal("Blue Stahli")
                        expect(album.artistid).to.equal(97145)
                        expect(album.thumbnail).to.equal("http://st.nhacso.net/images/album/2013/05/09/1072071738/136807196518_99_120x120.jpg")
                        expect( album.songs).to.eql([1285687,1285688,1285689,1285690,1285691,1285692,1285693,1285694,1285695,1285696,1285697,1285698])
                        done()
            it 'should contain 12 songs',(done)->
                  link = "http://nhacso.net/album/gettotalsong?listIds=#{album.albumid}"
                  getFileByHTTP link, (data)=>
                        data = JSON.parse data
                        strId = "nsn:album:total:song:id:#{album.albumid}"
                        nsongs = parseInt data.result[strId].TotalSong,10
                        expect(nsongs).to.equal(12)
                        done()
            it 'should be released in 2013 and has description ',(done)->
                  link = "http://nhacso.net/album/getdescandissuetime?listIds=#{album.albumid}"
                  getFileByHTTP link, (data)=>
                        data = JSON.parse(data).result[0]
                        # console.log data
                        released_date = data.IssueTime
                        description = ns.processStringorArray data.AlbumDesc
                        expect(parseInt(released_date,10)).to.equal(2013)
                        expect(description).to.equal("Label: FiXT\r\nGenre: Alternative")
                        done()
            it 'should have been played more than 42 times ',(done)->
                  link = "http://nhacso.net/statistic/albumtotallisten?listIds=#{album.albumid}"
                  getFileByHTTP link, (data)=>
                        data = JSON.parse(data)
                        plays = parseInt(data.result["#{album.albumid}"].totalListen,10)
                        expect(plays).to.be.above(42)
                        done()
      describe "Video ID: X15RV0N",->
            it 'should be called "Người Yêu Cũ" and has certain properties' ,(done)->
                  encoded_id = "X15RV0N"
                  link = "http://nhacso.net/xem-video/joke-link.#{encoded_id}=.html"
                  options = 
                        id : encode(encoded_id)
                  getFileByHTTP link, (data)=>
                        ns.getVideoDurationAndSublink = ->
                        video = ns.processVideo data,options
                        expect(video.videoid).to.equal(16040)
                        expect(video.title).to.equal("Người Yêu Cũ")
                        expect(video.artists).to.equal('["Phan Mạnh Quỳnh"]')
                        expect(video.topic).to.equal('Nhạc Trẻ')
                        expect(video.plays).to.be.at.least(1310)
                        expect(video.official).to.equal(1)
                        expect(video.producerid).to.equal(0)
                        expect(video.link).to.equal('http://st01.freesocialmusic.com/mp4/2013/05/09/1430055571/13680778242_4392.mp4')
                        expect(video.thumbnail).to.equal('http://st.nhacso.net/images/video/2013/05/09/1430055571/136807791310_2665_190x110.jpg')
                        expect(video.created).to.equal('2013-5-9 12:37:4')
                        done()
            it 'should have subtitle and 303 second long',(done)->
                  link = "http://nhacso.net/flash/video/xnl/1/id/" + ns._decodeId(video.videoid)
                  # console.log link
                  getFileByHTTP link, (data)=>
                        duration = parseInt(ns.getValueXML(data, "duration", 0).replace(/<\/duration>|<duration>/g,''),10)
                        sublink = ns.getValueXML data, "subUrl", 0
                        expect(duration).to.equal(303)
                        expect(sublink).to.equal("http://nhacso.net/flash/crypting/1/xnl/id/X15RV0M=")
                        done()
describe "THE WEBSITE MUSIC.GO.VN",->
      GM = require '../lib/gomusic'
      gm = new GM()
      describe "Song ID: 183352",->
            it 'should be called "Xa Mất Rồi" by "Thủy Tiên" and has certain properties',(done)->
                  link = "http://music.go.vn/Ajax/SongHandler.ashx?type=getsonginfo&sid=183352" 
                  getFileByHTTP link, (data)->
                        gm.connect()
                        gm.connection.query = -> 
                        song = gm._storeSong JSON.parse data
                        # console.log song
                        expect(song.SongId).to.equal(183352)
                        expect(song.SongName).to.equal('Xa Mất Rồi')
                        expect(song.ArtistId).to.equal(22054)
                        expect(song.ArtistName).to.equal('Thủy Tiên')
                        expect(song.ArtistDisplayName).to.equal('Thủy Tiên')
                        expect(song.TopicId).to.equal(69)
                        expect(song.TopicName).to.equal('Nhạc Trẻ')
                        expect(song.GenreId).to.equal(50)
                        expect(song.GenreName).to.equal('Dance / Electronic')
                        expect(song.RegionId).to.equal(27)
                        expect(song.RegionName).to.equal('Nhạc Việt Nam')
                        expect(song.Thumbnail).to.equal('/Album/2013/5/9/91FDCFCE4056D4BBB89743E0806A6208.jpg')
                        expect(song.Tags).to.equal('')
                        expect(song.Lyric).to.equal('<p><span>Và giờ này ... Đôi tay em không thể nào giữ lấy</span><br /><span>Từng kỷ niệm ... Mà theo em dần chìm vào quên lãng</span><br /><span>Cho nỗi buồn... Từng đêm kéo đến ... Và khiến nỗi nhớ như dài thêm</span><br /><br /><span>Còn lại gì ... Từ khi anh ra đi xa em mãi?</span><br /><span>Còn lại gì ... Một mình giờ này lạc trong tê tái ?</span><br /><span>Hỡi người ơi ... Tình yêu chúng ta ... Giờ là khúc ca ... Chẳng thế viết tiếp</span><br /><br /><span>ĐK : Và đến lúc em rời xa ... Con tim anh mới nhận ra</span><br /><span>Khoảnh khắc có em kề bên ... Ôi bao nhiêu phút êm đềm ...</span><br /><span>Mình đã xa mất rồi ... xa mất rồi ...</span><br /><span>Tìm đâu hơi ấm những lúc ta mặn nồng ...</span><br /><br /><span>Khoảnh khắc xa rời nhau ... anh buông đôi tay thật mau</span><br /><span>Dù biết em còn yêu ... Nhưng anh chẳng muốn quay lại ...</span><br /><span>Bỏ mặc em với nỗi đau ... Với kỉ niệm</span><br /><span>Tìm đâu hơi ấm, ký ức của hôm nào</span><br /><span>Đã xa mất rồi ...</span></p>')
                        expect(song.FilePath).to.equal('UserFiles/2013/5/9/zorba11/20130509105933.mp3')
                        expect(song.Bitrate).to.equal(320)
                        expect(song.Duration).to.equal(248)
                        expect(song.FileSize).to.equal(9928620)
                        expect(song.PlayCount).to.be.at.least(32)
                        expect(song.CreateTime).to.equal('2013-05-09')
                        expect(song.UpdateTime).to.equal('2013-05-09')
                        done()
      describe "Album ID: 18963",->    
            it 'should be called "Có Bao Điều" by "Tiêu Châu Như Quỳnh" and has certain properties ',(done)->
                  link = "http://music.go.vn/Ajax/AlbumHandler.ashx?type=getinfo&album=18963"
                  getFileByHTTP link, (data)->
                        gm.connect()
                        gm.connection.query = ->
                        album = gm._storeAlbum JSON.parse(data)
                        expect(album.AlbumId).to.equal(18963)
                        expect(album.AlbumName).to.equal('Có Bao Điều')
                        expect(album.MasterArtistId).to.equal(31996)
                        expect(album.MasterArtistName).to.equal('Tiêu Châu Như Quỳnh')
                        expect(album.TopicId).to.equal(69)
                        expect(album.TopicName).to.equal('Nhạc Trẻ')
                        expect(album.GenreId).to.equal(3)
                        expect(album.GenreName).to.equal('Pop')
                        expect(album.RegionId).to.equal(27)
                        expect(album.RegionName).to.equal('Nhạc Việt Nam')
                        expect(album.Duration).to.equal(1212)
                        expect(album.ReleaseDate).to.equal('2013-01-01')
                        expect(album.Tags).to.equal('')
                        expect(album.Thumbnail).to.equal('/Album/2013/5/8/4DBA6D485070AE248339AEC2C3B9DB14.jpg')
                        expect(album.Description).to.equal('<p><span>Album "C&oacute; bao điều" gồm 5 b&agrave;i h&aacute;t l&agrave; những giai điệu hiện đại thể hiện m&agrave;u sắc tươi tắn của tuổi trẻ, chứa chan t&igrave;nh cảm của một người con g&aacute;i y&ecirc;u đời.</span><br /><br /><span>Trong đ&oacute; c&oacute; 4 b&agrave;i do ch&iacute;nh Như Quỳnh s&aacute;ng t&aacute;c, ca kh&uacute;c "C&oacute; bao điều" viết về đề t&agrave;i x&atilde; hội với trăn trở của một c&ocirc; g&aacute;i trẻ qua những mảnh đời k&eacute;m may mắn v&agrave; niềm tin về một ng&agrave;y mai tươi s&aacute;ng hơn, "Đ&ocirc;i mắt đen" th&igrave; lại mang giai điệu nhẹ nh&agrave;ng, s&acirc;u lắng được Như Quỳnh s&aacute;ng t&aacute;c trong những năm học lớp 12 để d&agrave;nh tặng cho một người bạn th&acirc;n của m&igrave;nh, "Khoảng c&aacute;ch của đ&ocirc;i ta" chứa đựng cảm x&uacute;c day dứt khi hai người y&ecirc;u nhau m&agrave; kh&ocirc;ng thể đến với nhau do những định kiến khắc nghiệt của x&atilde; hội...</span></p>')
                        expect(album.SongCount).to.equal(5)
                        expect(album.PlayCount).to.be.at.least(1)
                        expect(album.CreateTime).to.equal('2013-05-08')
                        expect(album.UpdateTime).to.equal('2013-05-09')
                        done()
describe "THE WEBSITE NHAC.VUI.VN",->
      NV = require '../lib/nhacvui'
      nv = new NV()
      describe "Song ID: 183352",->
            it 'should be called "Anh Sẽ Quên" by "MT Phan" and has link property',(done)->
                  id = 318186
                  link = "http://hcm.nhac.vui.vn/asx2.php?type=1&id=#{318186}"
                  getFileByHTTP link, (data)->
                        nv.getSongStats = ->
                        xml2js = require 'xml2js'
                        parser = new xml2js.Parser()
                        parser.parseString data, (err, result) =>
                              song = result.rss.channel[0].item[0]
                              song = nv._storeSong id, song
                              expect(song.song_name).to.equal('Anh Sẽ Quên')
                              expect(song.artist_name).to.equal('MT Phan')
                              expect(song.link).to.equal('http://music-hcm.24hstatic.com/uploadmusic2/e4ee6c4db6d6f2cc130087823aff2a08/518d51cc/uploadmusic/id_chan/2-2013/huylun/Rap/NewTrack/128/Anh Se Quen - MT Phan.mp3')
                              done()
            it 'should have author, plays, topic, lyric properties',(done)->
                  id = 318186
                  link = "http://hcm.nhac.vui.vn/-m#{id}c2p1a1.html"
                  getFileByHTTP link, (data)->
                        item = 
                              song_name : ""
                              artist_name : ""
                              link : ""
                        song = nv.processSongCallback id, data, item
                        expect(parseInt(song.plays,10)).to.be.at.least(22)
                        expect(song.topic).to.equal('Rap Việt')
                        expect(song.author).to.equal('Rap Việt')
                        expect(song.lyric).to.equal('Anh sẽ quên - MT Phan [TPR]<br>màng đêm lạnh lắm...một mình ỡ nơi góc tối.. lòng lại buồn<br>nhưng anh không muốn suy nghĩ nhiều... không muốn nhớ em khi cơn mưa tuông<br>và không mong một điều.... là được bên em như lúc trước<br>vì người đã thay đỗi rồi..em lẵng lơ anh thẫn thờ...anh không ngờ được<br>ây giờ em khác xưa quá....anh nhìn mãi mà không ra<br>lời nói cữ chĩ đã thay đỗi... anh không hiễu được em... những suy nghĩ sâu xa<br>cãm giác trong anh vẫn đâu buồn... và anh sẽ cố gắn quên<br>quên đi em quên đi mọi thứ giữa 2 chúng ta.. lúc còn kề bên<br>hạnh phúc mãi bên nhau...thì cũng chỉ là lời hứa mà thoi<br>nếu như ngày xưa ta không yêu... thì bây giờ không cần nói<br>nếu như anh không gặp em... thì anh cũng đã khác xưa rồi<br>anh không trách gì em.... chỉ trách số phận mà mình đã chia 2 lối<br>không thễ bên nhau thật lâu.... trong khi thời gian đó qua rất nhanh<br>anh cũng quá ngu ngốc.. đã đễ em đi khi lòng này không đành<br>nhưng mà cãm ơn em nha... đã tạo cho anh cãm xúc buồn<br>để viết lên khúc nhạc....và đó là những đều mà anh muốn <br>và khoảnh khắc đó... em đã quên rồi<br>để mây kia mang mưa về nơi cuối trời<br>đễ hôm nay... tình ta<br>cũng đã không như lúc đầu<br>ồi cơn mưa kia... đã mang em đi<br>về một nơi thật xa ỡ nơi cuối trời<br>chỉ mong mưa<br>sẽ xóa đi.. kĩ niệm đau<br>những kĩ niệm đau cũa ngày đó....thì anh vẫn nhớ mà<br>là lúc mà em đã ra đi... em bỏ lại tất cã<br>để lại bao nhiêu kí ức ngày xưa rồi anh ôm trọn vào tim<br>nỗi nhớ vẫn bên anh.... những lúc vui buồn khi tình cãm đã lặng im<br>anh đã tìm về nơi đó..... nơi anh đã được bên em<br>nhìn cảnh vật ngày xưa nhưng giờ vắng lặng.. anh lại đau thêm<br>mưa rơi lất tất...lá thu cũng đã rơi đầy trên con đường mưa<br>anh nhìn thật lâu đễ rồi không thễ kìm được nước mắt nữa<br>nhiều lần anh đã mơ... rồi anh hy vọng em sẽ về<br>nhưng không.. chĩ là do anh tưỡng tượng ra trong cơn mê<br>và mưa mùa thu vẫn cứ rơi thật sự là anh rất nhớ đó<br>mưa ơi mưa đã quên rồi hay là mưa không còn nhớ rõ<br>mưa cố làm cho anh vui... rồi mưa lại cố làm anh thật buồn<br>mưa đến làm mát con tim... rồi mưa cũng đã tuông rất nhanh<br>lời cuối anh muốn nói...là anh cũng thật sự xin lỗi em<br>và đây sẽ là bài hát cuối cùng mà anh viết về em')
                        done()
      describe "Album ID: 26989",->
            it 'should be called "April\'s Spring" by "Forty" and has certain properties ',(done)->
                  id = 26989
                  link = "http://hcm.nhac.vui.vn/-a#{id}p1.html"
                  getFileByHTTP link, (data)->
                        result = nv.processAlbumData id, data
                        expect(result.album.aid).to.equal(26989)
                        expect(result.album.album_name).to.equal('April\'s Spring')
                        expect(result.album.album_artist).to.equal('Forty')
                        expect(result.album.topic).to.equal('Nhạc Hàn Quốc')
                        expect(parseInt(result.album.plays,10)).to.be.at.least(39)
                        expect(parseInt(result.album.nsongs,10)).to.equal(2)
                        expect(result.album.thumbnail).to.equal('http://nv-ad-hcm.24hstatic.com/upload/album/2-2013/1366001419_Aprils-Spring-Album-40-(Forty).jpg')
                        expect(result.album.created).to.equal('2013-4-1 11:50:19')
                        expect(result.songids).to.eql([ '314212', '314211' ])
                        done()