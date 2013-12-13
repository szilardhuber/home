(function() {
  var Parser, Plan, Wall;

  Parser = (function() {
    function Parser(text) {
      var groupname, i, line, object, tokens, _i, _len, _ref;
      this.count = 0;
      this.built = 0;
      this.objects = [];
      this.lines = text.split('\n');
      _ref = this.lines;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        line = _ref[i];
        line = line.trim();
        if (line.toLowerCase().substring(0, 2) === '# ') {
          groupname = line.substring(2, line.length);
          console.log("New group start here " + groupname);
        }
        if (line.trim().toLowerCase() === 'wall') {
          if (typeof object !== "undefined" && object !== null) {
            this.objects.push(object);
          }
          this.count++;
          object = [];
          object['type'] = 'wall';
        } else if (object != null) {
          tokens = line.split(':');
          if (tokens.length === 2) {
            object[tokens[0].trim()] = tokens[1].trim();
          }
        }
      }
      if (object != null) {
        this.objects.push(object);
      }
    }

    Parser.prototype.ended = function() {
      return this.built >= this.count;
    };

    Parser.prototype.get = function() {
      var coords, endx, endy, height, object, startx, starty, width;
      object = this.objects[this.built];
      switch (object['type']) {
        case 'wall':
          this.built++;
          if (object['start'] != null) {
            coords = object['start'].split(',');
            startx = parseFloat(coords[0].trim());
            starty = parseFloat(coords[1].trim());
          }
          if (object['end'] != null) {
            coords = object['end'].split(',');
            endx = parseFloat(coords[0].trim());
            endy = parseFloat(coords[1].trim());
          }
          if (object['height'] != null) {
            height = parseFloat(object['height'].trim());
          }
          if (object['width'] != null) {
            width = parseFloat(object['width'].trim());
          }
          if ((startx != null) && (starty != null) && (endx != null) && (endy != null) && (height != null) && (width != null)) {
            return new Wall(startx, starty, endx, endy, height, width);
          }
      }
    };

    return Parser;

  })();

  Plan = (function() {
    var ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH;

    WIDTH = 400;

    HEIGHT = 300;

    VIEW_ANGLE = 45;

    ASPECT = WIDTH / HEIGHT;

    NEAR = 0.1;

    FAR = 10000;

    function Plan() {
      this.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
      this.camera.rotation.x = -0.7;
      this.camera.position.z = 600;
      this.camera.position.y = 600;
      this.renderer = new THREE.WebGLRenderer();
      this.renderer.setSize(WIDTH, HEIGHT);
      this.scene = new THREE.Scene();
      this.scene.add(this.camera);
      this.pointLight = new THREE.AmbientLight(0xEEEEEE);
      this.pointLight.position.x = 10;
      this.pointLight.position.y = 50;
      this.pointLight.position.z = 130;
      this.scene.add(this.pointLight);
      this.stage = new Kinetic.Stage({
        container: floorplan,
        width: WIDTH,
        height: HEIGHT
      });
      this.layer = new Kinetic.Layer;
      this.stage.add(this.layer);
    }

    Plan.prototype.reset = function() {
      var child, children, _i, _len, _results;
      this.layer.removeChildren();
      children = this.scene.children.slice(0);
      _results = [];
      for (_i = 0, _len = children.length; _i < _len; _i++) {
        child = children[_i];
        if (child && child.name === "block") {
          _results.push(this.scene.remove(child));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Plan.prototype.draw = function() {
      this.renderer.render(this.scene, this.camera);
      return this.layer.batchDraw();
    };

    Plan.prototype.add = function(object) {
      object.mesh.name = "block";
      this.scene.add(object.mesh);
      this.layer.add(object.polygon);
      return this.draw();
    };

    Plan.prototype.fitToScreen = function() {
      var child, point, scaleX, scaleY, xMax, xMin, yMax, yMin, _i, _j, _len, _len1, _ref, _ref1;
      xMin = 0;
      xMax = 0;
      yMin = 0;
      yMax = 0;
      _ref = this.layer.children;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        _ref1 = child.getPoints();
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          point = _ref1[_j];
          if (xMin > point.x) {
            xMin = point.x;
          }
          if (xMax < point.x) {
            xMax = point.x;
          }
          if (yMin > point.y) {
            yMin = point.y;
          }
          if (yMax < point.y) {
            yMax = point.y;
          }
        }
      }
      scaleY = Math.abs(HEIGHT / (yMax - yMin));
      scaleX = Math.abs(WIDTH / (xMax - xMin));
      this.stage.setScaleY(-Math.min(scaleX, scaleY));
      this.stage.setScaleX(Math.min(scaleX, scaleY));
      this.stage.setOffsetY(yMax);
      return this.draw();
    };

    return Plan;

  })();

  $(function() {
    var $container, ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, plan;
    WIDTH = 400;
    HEIGHT = 300;
    VIEW_ANGLE = 45;
    ASPECT = WIDTH / HEIGHT;
    NEAR = 0.1;
    FAR = 10000;
    plan = new Plan();
    $('body').keypress(function(event) {
      switch (event.charCode) {
        case 119:
          plan.camera.position.z -= 10;
          break;
        case 97:
          plan.camera.position.x += 10;
          break;
        case 115:
          plan.camera.position.z += 10;
          break;
        case 100:
          plan.camera.position.x -= 10;
      }
      return plan.renderer.render(plan.scene, plan.camera);
    });
    $('#text').change(function(event) {
      var content, parser;
      plan.reset();
      content = event.target.value;
      parser = new Parser(content);
      while (!parser.ended()) {
        plan.add(parser.get());
      }
      return plan.fitToScreen();
    });
    $container = $("#container");
    $container.append(plan.renderer.domElement);
    $('textarea#text').change();
    return plan.draw();
  });

  Wall = (function() {
    function Wall(startx, starty, endx, endy, height, width) {
      var attributes, endx2, endy2, material, materials, sphereMaterial, startx2, starty2, texture, uniforms;
      this.startx = startx;
      this.starty = starty;
      this.endx = endx;
      this.endy = endy;
      this.height = height;
      this.width = width;
      texture = new THREE.Texture(this.generateTexture());
      texture.needsUpdate = true;
      uniforms = {
        texture: {
          type: 't',
          value: texture
        }
      };
      attributes = {};
      material = new THREE.ShaderMaterial({
        attributes: attributes,
        uniforms: uniforms,
        vertexShader: document.getElementById('vertex_shader').textContent,
        fragmentShader: document.getElementById('fragment_shader').textContent
      });
      materials = [
        new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), material, new THREE.MeshBasicMaterial({
          color: 0xCCCC00
        })
      ];
      sphereMaterial = new THREE.MeshFaceMaterial(materials);
      this.mesh = new THREE.Mesh(new THREE.CubeGeometry(this.length(), this.height, this.width), sphereMaterial);
      this.mesh.rotation.y = Math.atan((this.endy - this.starty) / (this.endx - this.startx));
      endx2 = this.endx + this.width * Math.sin(this.mesh.rotation.y);
      endy2 = this.endy - this.width * Math.cos(this.mesh.rotation.y);
      startx2 = this.startx + this.width * Math.sin(this.mesh.rotation.y);
      starty2 = this.starty - this.width * Math.cos(this.mesh.rotation.y);
      this.mesh.position.x = (endx2 + this.startx) / 2;
      this.mesh.position.z = -(endy2 + this.starty) / 2;
      this.polygon = new Kinetic.Polygon({
        points: [this.startx, this.starty, this.endx, this.endy, endx2, endy2, startx2, starty2],
        fill: 'green',
        stroke: 'black',
        strokeWidth: 4
      });
    }

    /*
    # OUTER WALLS
    	Wall, 0, -580, 0, 240, 270, 44
    	Wall, 44, 240, 990, 240, 270, 44
           Wall, 990, -580, 990, 240, 270, 44 
           Wall, 44, -536, 990, -536, 270, 44
    # BATHROOM
    	Wall, 315, 196, 315, -60, 270, 10
    	Wall, 44, 10, 137, 10, 270, 10
    	Wall, 211, 10, 305, 10, 270, 10
    	Wall, 137, 0, 137, -60, 270, 10
    	Wall, 221, 0, 221, -60, 270, 10
    # BEDROOM
           Wall, 315, -150, 315, -536, 270, 10
    
    
    	# OUTER WALLS
    	## height: 270
    	## width: 44
    	## right.color: #B1E74C
    	## start.z: 0
    	## end.z: 0
    	Wall
    		start: 0, -580
    		end: 0, 240
    	Wall
    		start: 44, 240
    		end: 990, 240
    	Wall
    		start: 990, -580
    		end: 990, 240
    	Wall
    		start: 44, -536
    		end: 990, -536
    
    	# BATHROOM
    	## height: 270
    	## width: 10
    	## right.color: #B1E74C
    	## start.z: 0
    	## end.z: 0
    	Wall
    		start 315, 196
    		end: 315, -6§
    	Wall
    		start: 44, 10
    		end: 137, 10
    	Wall
    		start: 211, 10
    		end: 305, 10
    	Wall
    		start: 137, 0
    		end: 137, -60
    	Wall
    		start: 221, 0
    		end: 221, -60
    
    	# BEDROOM
    	Wall
    		start: 315, -150, 0
    		end: 315, -536, 0
    		height: 270
    		with: 10
    		right.color: #B1E74C
    */


    Wall.prototype.generateTexture = function() {
      var canvas, context;
      canvas = document.createElement("canvas");
      canvas.width = this.length();
      canvas.height = this.height;
      context = canvas.getContext("2d");
      context.fillStyle = "rgba( 177, 231, 76, 1 )";
      context.fillRect(0, 0, this.length(), this.height);
      context.fillStyle = "rgba( 100, 81, 67, 1 )";
      context.fillRect(0, 0, this.length() / 3, this.height);
      return canvas;
    };

    Wall.prototype.length = function() {
      return Math.sqrt(Math.pow(this.startx - this.endx, 2) + Math.pow(this.starty - this.endy, 2));
    };

    return Wall;

  })();

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/