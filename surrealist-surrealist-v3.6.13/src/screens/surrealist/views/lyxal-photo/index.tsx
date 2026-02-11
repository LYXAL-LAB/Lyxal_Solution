import { mdiImage } from "@mdi/js";
import { PhotoTimeline } from "./components/PhotoTimeline";
import { Sidebar } from "./components/Sidebar";
import { Header } from "./components/Header";
import classes from "./components/style.module.scss";

export function LyxalPhotoView() {
    return (
        <div className={classes.root}>
            <Header />

            {/* Main Body: Sidebar + Content */}
            <div className={classes.main}>
                <Sidebar />
                <div className={classes.content}>
                    <div className={classes.timeline}>
                        <PhotoTimeline />
                    </div>
                    <div className={classes.footer}>
                        {/* Footer is empty and slimmer */}
                    </div>
                </div>
            </div>
        </div>
    );
}

export const LyxalPhotoIcon = mdiImage;
export const LyxalPhotoTitle = "Photos";
