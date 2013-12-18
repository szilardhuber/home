express = require('express');
PORT = 8002;
app = express();
//app.use('/settings', express.static(__dirname));
app.use(express["static"](__dirname));
app.listen(PORT);
