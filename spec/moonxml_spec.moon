package.path = '?/init.lua;?.lua;'..package.path
moonxml = require 'moonxml'

describe 'moonxml', ->
	setup ->
		--print = stub.new()

	for language in *{'html', 'xml'}
		describe "#{language} language", ->
			it 'should exist and be a table', ->
				assert.is.table moonxml[language]

			setup ->
				export lang = moonxml[language]
				lang.environment.print = stub.new()

			it 'should have a loadmoon function', ->
				assert.is.function lang.loadmoon
				assert.is.function lang.loadlua

			it 'should have a loadmoonfile function', ->
				assert.is.function lang.loadmoonfile
				assert.is.function lang.loadluafile

			it 'should load templates from strings', ->
				assert.is.function lang\loadmoon '-> "test"'

			it 'should fail on invalid moonscript', ->
				res, err = lang\loadmoon '->-><- yolo#'
				assert.is.nil res
				assert.is.string err

			it 'should load templates from files', ->
				assert.is.function lang\loadmoonfile 'example.moonxml'

			it 'should fail to load non-existant files', ->
				assert.has.errors (-> lang\loadmoonfile 'foo.bar'),
					'foo.bar: No such file or directory'
			
			it 'should escape text', ->
				lang\loadlua('p "<b>"')()
				with assert.stub(lang.environment.print)
					.was_not_called_with('<b>')
					.was_called_with('&lt;b&gt;')

			describe 'derived languages', ->
				setup ->
					export lang = moonxml[language]
					export lang = lang\derive!
					lang.environment.print = stub.new!

				it 'should escape text', ->
					lang\loadlua('p "<b>"')()
					with assert.stub(lang.environment.print)
						.was_not_called_with('<b>')
						.was_called_with('&lt;b&gt;')

			describe 'buffered languages', ->
				it 'should buffer text', ->
					buffered = lang\buffered!
					buffered\loadlua('h1("foo")')()
					assert.equal "<h1>foo</h1>", buffered.buffer\concat!
