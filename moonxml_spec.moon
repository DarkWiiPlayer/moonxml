package.path = './?.lua;'..package.path
moonxml = require 'moonxml'

describe 'moonxml', ->
	setup ->
		--print = stub.new()

	for language in *{'html', 'xml'}
		describe "#{language} language", ->
			it 'should exist and be a table', ->
				assert.is.table moonxml[language]

			setup -> export lang = moonxml[language]

			it 'should have a loadmoon function', ->
				assert.is.function lang.loadmoon
				assert.is.function lang.loadlua

			it 'should have a loadmoonfile function', ->
				assert.is.function lang.loadmoonfile
				assert.is.function lang.loadluafile

			it 'should load templates from strings', ->
				assert.is.function lang\loadmoon '-> "test"'

			it 'should fail on invalid moonscript', ->
				assert.is.nil lang\loadmoon '->-><- yolo#'

			it 'should load templates from files', ->
				assert.is.function lang\loadmoonfile 'example.moonxml'

			it 'should fail to load non-existant files', ->
				assert.has.errors (-> lang\loadmoonfile 'foo.bar'),
					'foo.bar: No such file or directory'
