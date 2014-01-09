(function() {
  var BuildingObject, Parser, Plan, Point, Slab, Wall,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BuildingObject = (function() {
    var geometry, sampleMaterial;

    function BuildingObject() {}

    sampleMaterial = void 0;

    geometry = void 0;

    BuildingObject.prototype.generateTexture = function(color, pattern, patternColor) {
      var canvas, context, point, _i, _len, _ref;
      if (color == null) {
        color = "#cccccc";
      }
      if (pattern == null) {
        pattern = void 0;
      }
      if (patternColor == null) {
        patternColor = void 0;
      }
      canvas = document.createElement("canvas");
      canvas.width = this.getLength();
      canvas.height = this.getHeight();
      context = canvas.getContext("2d");
      context.fillStyle = color;
      context.fillRect(0, 0, this.getLength(), this.getHeight());
      if (pattern != null) {
        context.fillStyle = patternColor;
        context.beginPath();
        context.moveTo(pattern[0].x, pattern[0].y);
        _ref = pattern.slice(1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          point = _ref[_i];
          context.lineTo(point.x, point.y);
        }
        context.closePath();
        context.fill();
      }
      return canvas;
    };

    BuildingObject.prototype.getMaterial = function(texture) {
      var material;
      if (BuildingObject.sampleMaterial == null) {
        BuildingObject.sampleMaterial = new THREE.MeshBasicMaterial();
      }
      material = BuildingObject.sampleMaterial.clone();
      material.map = texture;
      material.wrapAroud = true;
      return material;
    };

    BuildingObject.prototype.changeTexture = function(side, color, pattern, patternColor) {
      var texture;
      if (pattern == null) {
        pattern = void 0;
      }
      if (patternColor == null) {
        patternColor = void 0;
      }
      texture = new THREE.Texture(this.generateTexture(color, pattern, patternColor));
      texture.needsUpdate = true;
      texture.name = "" + side + "-" + color + "-" + pattern;
      this.mesh.material.materials[side].map = texture;
      this.mesh.material.materials[side].needsUpdate = true;
      this.mesh.geometry.faces[side * 2].materialIndex = side;
      this.mesh.geometry.faces[(side * 2) + 1].materialIndex = side;
      if (pattern != null) {
        return this.updateUVs(side);
      }
    };

    BuildingObject.prototype.updateUVs = function(side) {
      if (side === 0 || side === 1) {
        this.mesh.geometry.faceVertexUvs[0][side * 2] = [new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(1, 1)];
        return this.mesh.geometry.faceVertexUvs[0][(side * 2) + 1] = [new THREE.Vector2(1, 1), new THREE.Vector2(0, 1), new THREE.Vector2(0, 0)];
      } else {
        this.mesh.geometry.faceVertexUvs[0][side * 2] = [new THREE.Vector2(0, 0), new THREE.Vector2(1, 0), new THREE.Vector2(0, 1)];
        return this.mesh.geometry.faceVertexUvs[0][(side * 2) + 1] = [new THREE.Vector2(1, 0), new THREE.Vector2(1, 1), new THREE.Vector2(0, 1)];
      }
    };

    return BuildingObject;

  })();

  Point = (function() {
    function Point(x, y) {
      this.x = x;
      this.y = y;
    }

    return Point;

  })();

  Parser = (function() {
    function Parser(text) {
      var arrayTyped, globals, groupname, i, isInGlobalSection, key, line, name, object, tokens, v, value, _i, _len, _ref, _ref1;
      this.count = 0;
      this.built = 0;
      this.objects = [];
      this.lines = text.split('\n');
      globals = [];
      isInGlobalSection = false;
      _ref = this.lines;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        line = _ref[i];
        line = line.trim();
        if (line.substring(0, 2) === '# ') {
          groupname = line.substring(2, line.length);
          isInGlobalSection = true;
          globals = [];
        } else if (isInGlobalSection && line.substring(0, 3) === '## ') {
          line = line.substring(3, line.length);
          tokens = line.split(':');
          globals[tokens[0].trim()] = tokens[1].trim();
        } else if (line.trim().toLowerCase() === 'wall') {
          isInGlobalSection = false;
          if (typeof object !== "undefined" && object !== null) {
            this.objects.push(object);
          }
          this.count++;
          object = [];
          object['type'] = 'wall';
          for (key in globals) {
            object[key] = globals[key];
          }
        } else if (line.trim().toLowerCase() === 'slab') {
          isInGlobalSection = false;
          if (object != null) {
            this.objects.push(object);
          }
          this.count++;
          object = [];
          object['type'] = 'slab';
          for (key in globals) {
            object[key] = globals[key];
          }
        } else if (object != null) {
          tokens = line.split(':');
          if (tokens.length === 2) {
            arrayTyped = false;
            name = tokens[0].trim();
            if (name.substring(0, 1) === "-") {
              arrayTyped = true;
              name = name.substring(2, name.length);
            }
            value = tokens[1].trim();
            if (!(name in object) || !arrayTyped) {
              object[name] = value;
            } else if (((_ref1 = object[name]) != null ? _ref1.push : void 0) != null) {
              object[name].push(value);
            } else {
              v = [];
              v.push(object[name]);
              v.push(value);
              object[name] = v;
            }
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
      var coords, endx, endy, height, object, pattern, points, slab, startx, starty, vertex, vertices, wall, width, _i, _len, _ref;
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
            wall = new Wall(startx, starty, endx, endy, height, width);
            if (object['bottom.color'] != null) {
              wall.changeTexture(0, object['bottom.color']);
            }
            if (object['top.color'] != null) {
              wall.changeTexture(1, object['top.color']);
            }
            if (object['right.color'] != null) {
              if (startx === 44 && starty === 240 && endx === 990 && endy === 240) {
                pattern = [];
                pattern.push(new Point(160, 0));
                pattern.push(new Point(160, 270));
                pattern.push(new Point(260, 270));
                pattern.push(new Point(260, 0));
                wall.changeTexture(2, object['right.color'], pattern, "#645143");
              } else {
                wall.changeTexture(2, object['right.color']);
              }
            }
            if (object['rear.color'] != null) {
              wall.changeTexture(3, object['rear.color']);
            }
            if (object['left.color'] != null) {
              wall.changeTexture(4, object['left.color']);
            }
            if (object['front.color'] != null) {
              wall.changeTexture(5, object['front.color']);
            }
            return wall;
          }
          break;
        case 'slab':
          console.log(object['point']);
          this.built++;
          vertices = [];
          _ref = object['point'];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            vertex = _ref[_i];
            points = vertex.split(',');
            vertices.push(new THREE.Vector3(parseInt(points[0].trim()), parseInt(points[1].trim()), parseInt(points[2].trim())));
          }
          slab = new Slab(vertices, 40, object['color']);
          if (object['bottom.color'] != null) {
            slab.changeTexture(0, object['bottom.color']);
          }
          if (object['top.color'] != null) {
            pattern = [];
            pattern.push(new Point(0, 20));
            pattern.push(new Point(0, 100));
            pattern.push(new Point(100, 100));
            pattern.push(new Point(100, 60));
            slab.changeTexture(1, object['top.color'], pattern, "#645143");
          }
          if (object['right.color'] != null) {
            slab.changeTexture(2, object['right.color']);
          }
          if (object['rear.color'] != null) {
            slab.changeTexture(3, object['rear.color']);
          }
          if (object['left.color'] != null) {
            slab.changeTexture(4, object['left.color']);
          }
          if (object['front.color'] != null) {
            slab.changeTexture(5, object['front.color']);
          }
          return slab;
      }
    };

    return Parser;

  })();

  Plan = (function() {
    var ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH;

    WIDTH = 1500;

    HEIGHT = 800;

    VIEW_ANGLE = 75;

    ASPECT = WIDTH / HEIGHT;

    NEAR = 1;

    FAR = 10000;

    function Plan() {
      this.draw = __bind(this.draw, this);
      var d, dirLight, hemiLight;
      this.renderer = new THREE.WebGLRenderer();
      this.renderer.setSize(WIDTH, HEIGHT);
      this.renderer.setClearColor(0xf0f0f0);
      this.renderer.sortObjects = false;
      this.renderer.shadowMapEnabled = true;
      this.renderer.shadowMapType = THREE.PCFShadowMap;
      this.optimize = false;
      this.camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
      this.camera.position = new THREE.Vector3(100, -200, 160);
      this.controls = new THREE.FirstPersonControls(this.camera, this.renderer.domElement);
      this.controls.movementSpeed = 300;
      this.controls.lookSpeed = 0.25;
      this.controls.lookVertical = true;
      this.controls.dragToLook = true;
      this.controlsEnabled = true;
      this.scene = new THREE.Scene();
      this.scene.add(this.camera);
      hemiLight = new THREE.HemisphereLight(0xffffff, 0xffffff, 0.9);
      hemiLight.color.setHSL(0.6, 0.75, 0.5);
      hemiLight.groundColor.setHSL(0.095, 0.5, 0.5);
      hemiLight.position.set(0, 0, 500);
      this.scene.add(hemiLight);
      dirLight = new THREE.DirectionalLight(0xffffff, 1);
      dirLight.position.set(-1, -1, 0.75);
      dirLight.position.multiplyScalar(50);
      dirLight.name = "dirlight";
      this.scene.add(dirLight);
      dirLight.castShadow = true;
      dirLight.shadowMapWidth = dirLight.shadowMapHeight = 1024 * 2;
      d = 300;
      dirLight.shadowCameraLeft = -d;
      dirLight.shadowCameraRight = d;
      dirLight.shadowCameraTop = d;
      dirLight.shadowCameraBottom = -d;
      dirLight.shadowCameraFar = 3500;
      dirLight.shadowBias = -0.0001;
      dirLight.shadowDarkness = 0.15;
      Wall.prototype.geometry = new THREE.Geometry;
      this.materials = [];
      this.clock = new THREE.Clock();
      this.stage = new Kinetic.Stage({
        container: floorplan,
        width: WIDTH,
        height: HEIGHT
      });
      this.layer = new Kinetic.Layer;
      this.stage.add(this.layer);
      this.switchViewMode();
      this.draw();
    }

    Plan.prototype.reset = function() {
      var child, children, _i, _len, _results;
      this.materialIndex = 4;
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
      var _this = this;
      setTimeout((function() {
        return requestAnimationFrame(_this.draw);
      }), 1000 / 30);
      if (this.controlsEnabled) {
        this.controls.update(this.clock.getDelta());
      }
      this.renderer.render(this.scene, this.camera);
      return this.layer.batchDraw();
    };

    Plan.prototype.add = function(object) {
      var face, i, _i, _len, _ref;
      object.mesh.name = "block";
      if (!this.optimize) {
        this.scene.add(object.mesh);
      } else {
        _ref = object.mesh.geometry.faces;
        for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
          face = _ref[i];
          if (i % 2 === 0) {
            this.materials.push(object.mesh.material.materials[i / 2]);
          }
          face.materialIndex = this.materials.length - 1;
        }
        THREE.GeometryUtils.merge(Wall.prototype.geometry, object.mesh);
      }
      if (object.polygon != null) {
        return this.layer.add(object.polygon);
      }
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
      return this.stage.setOffsetY(yMax);
    };

    Plan.prototype.switchViewMode = function() {
      if (this.controlsEnabled) {
        this.controlsEnabled = false;
        this.savedCameraPosition = this.camera.position;
        this.camera.position = new THREE.Vector3(400, -600, 700);
        return this.camera.lookAt(new THREE.Vector3(400, 0, 0));
      } else {
        this.controlsEnabled = true;
        if (this.savedCameraPosition != null) {
          return this.camera.position = this.savedCameraPosition;
        } else {
          return this.camera.position = new THREE.Vector3(0, 0, 0);
        }
      }
    };

    return Plan;

  })();

  $(function() {
    var $container, plan;
    plan = new Plan();
    $('body').keypress(function(event) {
      switch (event.charCode) {
        case 99:
          return plan.switchViewMode();
      }
    });
    $('#text').change(function(event) {
      var content, mesh, parser;
      plan.reset();
      content = event.target.value;
      parser = new Parser(content);
      while (!parser.ended()) {
        plan.add(parser.get());
      }
      mesh = new THREE.Mesh(Wall.prototype.geometry, new THREE.MeshFaceMaterial(plan.materials));
      mesh.castShadow = true;
      mesh.receiveShadow = true;
      console.log(plan.materials);
      plan.scene.add(mesh);
      return plan.fitToScreen();
    });
    $container = $("#container");
    $container.append(plan.renderer.domElement);
    $('textarea#text').change();
    return plan.draw();
  });

  Slab = (function(_super) {
    __extends(Slab, _super);

    function Slab(vertices, height, color) {
      var materials, texture;
      this.vertices = vertices;
      this.height = height;
      if (color == null) {
        color = void 0;
      }
      texture = new THREE.Texture(this.generateTexture(color));
      texture.needsUpdate = true;
      materials = [this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture)];
      this.mesh = new THREE.Mesh(new this.createGeometry(this.vertices, this.height), new THREE.MeshFaceMaterial(materials));
      this.mesh.castShadow = true;
      this.mesh.receiveShadow = true;
      /*
      		# TODO display slabs on 2d
      		@polygon = new Kinetic.Polygon
      			points: [@startx, @starty, @endx, @endy, endx2, endy2, startx2, starty2]
      			fill: 'green'
      			stroke: 'black'
      			strokeWidth: 4
      */

    }

    Slab.prototype.createGeometry = function(polygon, height) {
      var extrudeSettings, first, geometry, shape, vertex, _i, _len;
      geometry = new THREE.Geometry();
      shape = new THREE.Shape();
      first = true;
      for (_i = 0, _len = polygon.length; _i < _len; _i++) {
        vertex = polygon[_i];
        if (first) {
          shape.moveTo(vertex.x, vertex.y);
          first = false;
        } else {
          shape.lineTo(vertex.x, vertex.y);
        }
      }
      shape.lineTo(polygon[0].x, polygon[0].y);
      extrudeSettings = {
        amount: height
      };
      extrudeSettings.bevelEnabled = false;
      return new THREE.ExtrudeGeometry(shape, extrudeSettings);
    };

    Slab.prototype.getLength = function() {
      return 100;
    };

    Slab.prototype.getHeight = function() {
      return 100;
    };

    return Slab;

  })(BuildingObject);

  Wall = (function(_super) {
    __extends(Wall, _super);

    function Wall(startx, starty, endx, endy, height, width) {
      var endx2, endy2, materials, rotation, startx2, starty2, texture;
      this.startx = startx;
      this.starty = starty;
      this.endx = endx;
      this.endy = endy;
      this.height = height;
      this.width = width;
      texture = new THREE.Texture(this.generateTexture());
      texture.needsUpdate = true;
      materials = [this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture), this.getMaterial(texture)];
      this.mesh = new THREE.Mesh(this.createGeometry(this.startx, this.starty, this.endx, this.endy, this.height, this.width), new THREE.MeshFaceMaterial(materials));
      this.mesh.castShadow = true;
      this.mesh.receiveShadow = true;
      rotation = Math.atan((this.endy - this.starty) / (this.endx - this.startx));
      endx2 = this.endx + this.width * Math.sin(rotation);
      endy2 = this.endy - this.width * Math.cos(rotation);
      startx2 = this.startx + this.width * Math.sin(rotation);
      starty2 = this.starty - this.width * Math.cos(rotation);
      this.polygon = new Kinetic.Polygon({
        points: [this.startx, this.starty, this.endx, this.endy, endx2, endy2, startx2, starty2],
        fill: 'green',
        stroke: 'black',
        strokeWidth: 4
      });
    }

    Wall.prototype.createGeometry = function(startx, starty, endx, endy, height, width) {
      var endx2, endy2, extrudeSettings, rotation, shape, startx2, starty2;
      shape = new THREE.Shape();
      rotation = Math.atan((this.endy - this.starty) / (this.endx - this.startx));
      endx2 = endx + width * Math.sin(rotation);
      endy2 = endy - width * Math.cos(rotation);
      startx2 = startx + width * Math.sin(rotation);
      starty2 = starty - width * Math.cos(rotation);
      shape.moveTo(startx, starty);
      shape.lineTo(endx, endy);
      shape.lineTo(endx2, endy2);
      shape.lineTo(startx2, starty2);
      shape.lineTo(startx, starty);
      extrudeSettings = {
        amount: height
      };
      extrudeSettings.bevelEnabled = false;
      return new THREE.ExtrudeGeometry(shape, extrudeSettings);
    };

    Wall.prototype.getLength = function() {
      return Math.sqrt(Math.pow(this.startx - this.endx, 2) + Math.pow(this.starty - this.endy, 2));
    };

    Wall.prototype.getHeight = function() {
      return this.height;
    };

    return Wall;

  })(BuildingObject);

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/