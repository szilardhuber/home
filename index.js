(function() {
  var Wall;

  $(function() {
    var $container, ASPECT, FAR, HEIGHT, NEAR, VIEW_ANGLE, WIDTH, camera, pointLight, renderer, scene, wall, wall2, wall3;
    WIDTH = 400;
    HEIGHT = 300;
    VIEW_ANGLE = 45;
    ASPECT = WIDTH / HEIGHT;
    NEAR = 0.1;
    FAR = 10000;
    camera = new THREE.PerspectiveCamera(VIEW_ANGLE, ASPECT, NEAR, FAR);
    camera.rotation.x = -0.7;
    $('body').keypress(function(event) {
      switch (event.charCode) {
        case 119:
          camera.position.z -= 10;
          break;
        case 115:
          camera.position.z += 10;
          break;
        case 97:
          camera.position.x += 10;
          break;
        case 100:
          camera.position.x -= 10;
      }
      return renderer.render(scene, camera);
    });
    $container = $("#container");
    renderer = new THREE.WebGLRenderer();
    scene = new THREE.Scene();
    scene.add(camera);
    camera.position.z = 600;
    camera.position.y = 600;
    renderer.setSize(WIDTH, HEIGHT);
    $container.append(renderer.domElement);
    wall = new Wall(0, 240, 270, 240, 270, 44);
    wall2 = new Wall(0, 0, 0, 240, 270, 44);
    wall3 = new Wall(270, 240, 270, 0, 270, 10);
    scene.add(wall.mesh);
    scene.add(wall2.mesh);
    scene.add(wall3.mesh);
    pointLight = new THREE.AmbientLight(0xEEEEEE);
    pointLight.position.x = 10;
    pointLight.position.y = 50;
    pointLight.position.z = 130;
    scene.add(pointLight);
    return renderer.render(scene, camera);
  });

  Wall = (function() {
    function Wall(startx, starty, endx, endy, height, width) {
      var materials, sphereMaterial;
      this.startx = startx;
      this.starty = starty;
      this.endx = endx;
      this.endy = endy;
      this.height = height;
      this.width = width;
      materials = [
        new THREE.MeshBasicMaterial({
          color: 0xAACC00
        }), new THREE.MeshBasicMaterial({
          color: 0xCCCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xBBCC00
        }), new THREE.MeshBasicMaterial({
          color: 0xAACC00
        }), new THREE.MeshBasicMaterial({
          color: 0xCC0000
        }), new THREE.MeshBasicMaterial({
          color: 0xCCCC00
        })
      ];
      sphereMaterial = new THREE.MeshFaceMaterial(materials);
      this.mesh = new THREE.Mesh(new THREE.CubeGeometry(this.length(), this.height, this.width), sphereMaterial);
      this.mesh.position.x = (this.startx + this.endx) / 2 + (this.width / 2);
      this.mesh.position.z = -((this.starty + this.endy) / 2 + (this.width / 2));
      this.mesh.rotation.y = Math.atan((this.endy - this.starty) / (this.endx - this.startx));
    }

    Wall.prototype.length = function() {
      return Math.sqrt(Math.pow(this.startx - this.endx, 2) + Math.pow(this.starty - this.endy, 2));
    };

    return Wall;

  })();

}).call(this);

/*
//@ sourceMappingURL=index.js.map
*/