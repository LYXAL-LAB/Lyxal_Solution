import { DavServer } from './server';
import { DatabaseService } from './database';

console.log("Lyxal_Dav Service Initializing...");

// Connect to Database
const db = DatabaseService.getInstance();
db.connect("lyxal", "calendar").then(() => {
    // Start Server
    const server = new DavServer(3000);
    server.start();
}).catch(err => {
    console.error("Failed to initialize service:", err);
    process.exit(1);
});
