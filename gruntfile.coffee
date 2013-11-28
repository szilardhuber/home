module.exports = (grunt) ->
	grunt.initConfig
		pkg:
			grunt.file.readJSON 'package.json'
		mkdir:
			all: options: create: ['deploy', 'deploy/libs', 'deploy/partials', 'out', 'out/partials', 'out/libs']
		coffee:
			compile:
				options: sourceMap: true, join: true
				files: 'out/index.js': ['src/*.coffee']
		jade:
			compile_index:
				options: data: development: true
				files: "out/index.html": "src/index.jade"
			compile_partials:
				options: data: development: true
				files: [ expand: true, dest: 'out/partials/', ext: '.html', cwd:'src/partials', src: ['*.jade'] ]
			deploy_index:
				options: data: development: false
				files: "out/index.html": "src/index.jade"
			deploy_partials:
				options: data: development: false
				files: [ expand: true, dest: 'out/partials/', ext: '.html', cwd:'src/partials', src: ['*.jade'] ]
		uglify:
			options: banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
			build:
				src: 'out/index.js'
				dest: 'out/index.min.js'
		copy:
			map:         files: [ expand: true, cwd: 'out',  dest: 'out/',        src: ['*.map'] ]
			deploy_out:  files: [ expand: true, cwd: 'out',  dest: 'deploy/',     src: ['*.html', '*.css', '*.min.js'] ]
			deploy_test: files: [ expand: true, cwd: 'test', dest: 'deploy/',     src: ['*.ics'] ]
			deploy_libs: files: [ expand: true, cwd: 'bower_components', flatten: true, dest: 'deploy/libs', src: ['**/*.min.js', '**/*.min.css'] ]
			deploy_fonts: files: [ expand: true, cwd: 'bower_components', flatten: true, dest: 'deploy/fonts', src: ['**/fonts/*'] ]
			out_libs: files:  [ expand: true, cwd: 'bower_components', flatten: true, dest: 'out/libs', src: ['**/*.min.js', '**/*.min.css'] ]
			out_fonts: files: [ expand: true, cwd: 'bower_components', flatten: true, dest: 'out/fonts', src: ['**/fonts/*'] ]
		replace:
			javascript:
				src: ['deploy/index.html']
				dest: ['deploy/index.html']
				replacements: [
					(
						from: 'index.js'
						to: 'index.min.js'
					)
				]
			
		watch:
			options: 
				spawn: false
				livereload: true
			grunt:
				files: ['gruntfile.coffee']
				tasks: ['init', 'copy:out_libs', 'copy:out_fonts', 'coffee', 'copy:map', 'jade:compile_index', 'jade:compile_partials']
			coffee:
				files: ['src/*.coffee']
				tasks: ['coffee', 'copy:map']
			jade:
				files: ['src/**/*.jade']
				tasks: ['jade:compile_index', 'jade:compile_partials']

	grunt.loadNpmTasks 'grunt-mkdir'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-jade'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks('grunt-text-replace');
	grunt.loadNpmTasks('grunt-notify');
	
	grunt.registerTask 'init', ['mkdir']
	grunt.registerTask 'copy_deploy', ['copy:deploy_out', 'copy:deploy_libs', 'copy:deploy_fonts','copy:deploy_test']
	grunt.registerTask 'replace_paths', ['replace:javascript']
	grunt.registerTask 'deploy', ['init', 'coffee', 'jade:deploy_index', 'jade:deploy_partials', 'uglify', 'copy_deploy', 'replace_paths']
	grunt.registerTask 'debug', ['init', 'coffee', 'jade:compile_index', 'jade:compile_partials', 'copy:out_libs', 'copy:out_fonts']
	grunt.registerTask 'default', ['watch']

