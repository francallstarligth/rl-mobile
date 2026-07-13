.class public final Lradiant/RLAPILyricsWorker;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;


# instance fields
.field public final vm:Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;

.field public final title:Ljava/lang/String;

.field public final artist:Ljava/lang/String;

.field public final key:Ljava/lang/String;

.field public final lyricsId:Ljava/lang/String;


# direct methods
.method public constructor <init>(Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lradiant/RLAPILyricsWorker;->vm:Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;

    iput-object p2, p0, Lradiant/RLAPILyricsWorker;->title:Ljava/lang/String;

    iput-object p3, p0, Lradiant/RLAPILyricsWorker;->artist:Ljava/lang/String;

    iput-object p4, p0, Lradiant/RLAPILyricsWorker;->key:Ljava/lang/String;

    iput-object p5, p0, Lradiant/RLAPILyricsWorker;->lyricsId:Ljava/lang/String;

    return-void
.end method

.method public static fetch(Ljava/lang/String;Z)Ljava/lang/String;
    .locals 7

    :try_start
    new-instance v0, Ljava/net/URL;

    invoke-direct {v0, p0}, Ljava/net/URL;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/net/URL;->openConnection()Ljava/net/URLConnection;

    move-result-object v0

    check-cast v0, Ljava/net/HttpURLConnection;

    const-string v1, "GET"

    invoke-virtual {v0, v1}, Ljava/net/HttpURLConnection;->setRequestMethod(Ljava/lang/String;)V

    const v1, 0x2710

    invoke-virtual {v0, v1}, Ljava/net/URLConnection;->setConnectTimeout(I)V

    invoke-virtual {v0, v1}, Ljava/net/URLConnection;->setReadTimeout(I)V

    if-eqz p1, :no_auth

    const-string v1, "P-Access-Token-Id"

    const-string v2, "58hy4s86"

    invoke-virtual {v0, v1, v2}, Ljava/net/URLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "P-Access-Token"

    const-string v2, "xjehy2lfg5h5mjwotoxrcqugam"

    invoke-virtual {v0, v1, v2}, Ljava/net/URLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    const-string v1, "x-client-ip"

    const-string v2, "null"

    invoke-virtual {v0, v1, v2}, Ljava/net/URLConnection;->setRequestProperty(Ljava/lang/String;Ljava/lang/String;)V

    :no_auth
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getResponseCode()I

    move-result v1

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "fetch status="

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v4, " url="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v3}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    const/16 v2, 0xc8

    if-eq v1, v2, :status_ok

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V

    const/4 v1, 0x0

    return-object v1

    :status_ok
    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->getInputStream()Ljava/io/InputStream;

    move-result-object v1

    new-instance v2, Ljava/io/InputStreamReader;

    const-string v3, "UTF-8"

    invoke-direct {v2, v1, v3}, Ljava/io/InputStreamReader;-><init>(Ljava/io/InputStream;Ljava/lang/String;)V

    new-instance v3, Ljava/io/BufferedReader;

    invoke-direct {v3, v2}, Ljava/io/BufferedReader;-><init>(Ljava/io/Reader;)V

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    :read_loop
    invoke-virtual {v3}, Ljava/io/BufferedReader;->readLine()Ljava/lang/String;

    move-result-object v5

    if-eqz v5, :read_done

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const/16 v5, 0xa

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    goto :read_loop

    :read_done
    invoke-virtual {v3}, Ljava/io/BufferedReader;->close()V

    invoke-virtual {v0}, Ljava/net/HttpURLConnection;->disconnect()V

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    return-object v6

    :try_end
    .catchall {:try_start .. :try_end} :catch_all

    :catch_all
    move-exception v0

    new-instance v1, Ljava/lang/StringBuilder;

    const-string v2, "fetch exception url="

    invoke-direct {v1, v2}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v2, " err="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v0}, Ljava/lang/Throwable;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v1}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    const/4 v1, 0x0

    return-object v1
.end method

.method public static parseLines(Ljava/lang/String;)Ljava/util/ArrayList;
    .locals 11

    :try_start
    new-instance v0, Lorg/json/JSONObject;

    invoke-direct {v0, p0}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string v1, "type"

    const-string v2, ""

    invoke-virtual {v0, v1, v2}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "Line"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :type_ok

    const-string v2, "Word"

    invoke-virtual {v2, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-nez v2, :type_ok

    const/4 v0, 0x0

    return-object v0

    :type_ok
    const-string v1, "data"

    invoke-virtual {v0, v1}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v0

    if-nez v0, :data_ok

    const/4 v0, 0x0

    return-object v0

    :data_ok
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I

    move-result v1

    if-nez v1, :nonempty

    const/4 v0, 0x0

    return-object v0

    :nonempty
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2, v1}, Ljava/util/ArrayList;-><init>(I)V

    const/4 v3, 0x0

    :loop
    if-ge v3, v1, :loop_done

    invoke-virtual {v0, v3}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v4

    const-string v5, "text"

    const-string v6, ""

    invoke-virtual {v4, v5, v6}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    const-string v6, "startTime"

    const-wide/16 v7, 0x0

    invoke-virtual {v4, v6, v7, v8}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v7

    const-wide v9, 0x408f400000000000L

    mul-double/2addr v7, v9

    double-to-long v7, v7

    new-instance v4, Lcom/tidal/android/feature/playerscreen/ui/f;

    invoke-direct {v4, v5, v7, v8}, Lcom/tidal/android/feature/playerscreen/ui/f;-><init>(Ljava/lang/String;J)V

    invoke-virtual {v2, v4}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    add-int/lit8 v3, v3, 0x1

    goto :loop

    :loop_done
    return-object v2

    :try_end
    .catchall {:try_start .. :try_end} :catch_all

    :catch_all
    move-exception v0

    const/4 v1, 0x0

    return-object v1
.end method

.method private runImpl()V
    .locals 11

    iget-object v0, p0, Lradiant/RLAPILyricsWorker;->title:Ljava/lang/String;

    const-string v1, "UTF-8"

    invoke-static {v0, v1}, Ljava/net/URLEncoder;->encode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iget-object v2, p0, Lradiant/RLAPILyricsWorker;->artist:Ljava/lang/String;

    invoke-static {v2, v1}, Ljava/net/URLEncoder;->encode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    new-instance v2, Ljava/lang/StringBuilder;

    const-string v3, "?title="

    invoke-direct {v2, v3}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "&artist="

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    const-string v0, "&platform=rl-mobile"

    invoke-virtual {v2, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "https://api.atomix.one/rl-api"

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x1

    invoke-static {v3, v4}, Lradiant/RLAPILyricsWorker;->fetch(Ljava/lang/String;Z)Ljava/lang/String;

    move-result-object v3

    if-nez v3, :got_body

    new-instance v3, Ljava/lang/StringBuilder;

    const-string v4, "https://rl-api.kineticsand.net/lyrics"

    invoke-direct {v3, v4}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v3, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x0

    invoke-static {v3, v4}, Lradiant/RLAPILyricsWorker;->fetch(Ljava/lang/String;Z)Ljava/lang/String;

    move-result-object v3

    if-nez v3, :got_body

    const-string v4, "both primary and fallback fetches failed"

    invoke-static {v4}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    iget-object v4, p0, Lradiant/RLAPILyricsWorker;->key:Ljava/lang/String;

    sget-object v5, Lradiant/RLAPILyricsHook;->currentKey:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :no_close    # Smthn needed to keep lyrics open

    sget-boolean v4, Lradiant/StickyLyrics;->enabled:Z

    if-nez v4, :no_close

    iget-object v4, p0, Lradiant/RLAPILyricsWorker;->vm:Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;

    iget-object v5, v4, Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;->P:Lkotlinx/coroutines/flow/MutableStateFlow;

    sget-object v6, Ljava/lang/Boolean;->FALSE:Ljava/lang/Boolean;

    invoke-interface {v5, v6}, Lkotlinx/coroutines/flow/MutableStateFlow;->setValue(Ljava/lang/Object;)V

    :no_close
    return-void

    :got_body
    invoke-static {v3}, Lradiant/RLAPILyricsWorker;->parseLines(Ljava/lang/String;)Ljava/util/ArrayList;

    move-result-object v3

    if-nez v3, :parse_ok

    const-string v4, "parse returned null (bad JSON / unsupported type)"

    invoke-static {v4}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    return-void

    :parse_ok
    invoke-virtual {v3}, Ljava/util/ArrayList;->size()I

    move-result v4

    if-nez v4, :nonempty

    const-string v5, "parsed 0 lines"

    invoke-static {v5}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    return-void

    :nonempty
    new-instance v5, Ljava/lang/StringBuilder;

    const-string v6, "parsed "

    invoke-direct {v5, v6}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    const-string v6, " lines"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v5}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    iget-object v4, p0, Lradiant/RLAPILyricsWorker;->key:Ljava/lang/String;

    sget-object v5, Lradiant/RLAPILyricsHook;->currentKey:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :key_ok

    const-string v5, "race-check failed (user skipped tracks)"

    invoke-static {v5}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    return-void

    :key_ok
    iget-object v4, p0, Lradiant/RLAPILyricsWorker;->vm:Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;

    iget-object v5, v4, Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;->O:Lkotlinx/coroutines/flow/MutableStateFlow;

    invoke-static {v3}, Lvn0/a;->c(Ljava/lang/Iterable;)Lvn0/b;

    move-result-object v6

    iget-object v7, p0, Lradiant/RLAPILyricsWorker;->lyricsId:Ljava/lang/String;

    if-nez v7, :have_id

    const-string v7, ""

    :have_id
    new-instance v8, Lcom/tidal/android/feature/playerscreen/ui/g$c;

    const/4 v9, -0x1

    const/4 v10, 0x0

    invoke-direct {v8, v7, v6, v9, v10}, Lcom/tidal/android/feature/playerscreen/ui/g$c;-><init>(Ljava/lang/String;Lvn0/b;IZ)V

    const-string v6, "publishing g$c -> K=true (O=true if sticky) N=g$c"

    invoke-static {v6}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    const/4 v6, 0x1

    sput-boolean v6, Lradiant/RLAPILyricsHook;->isRlState:Z

    iget-object v6, v4, Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;->K:Lkotlinx/coroutines/flow/MutableStateFlow;

    sget-object v7, Ljava/lang/Boolean;->TRUE:Ljava/lang/Boolean;

    invoke-interface {v6, v7}, Lkotlinx/coroutines/flow/MutableStateFlow;->setValue(Ljava/lang/Object;)V

    sget-boolean v9, Lradiant/StickyLyrics;->enabled:Z

    if-eqz v9, :skip_n

    iget-object v6, v4, Lcom/tidal/android/feature/playerscreen/ui/PlayerViewModel;->P:Lkotlinx/coroutines/flow/MutableStateFlow;

    invoke-interface {v6, v7}, Lkotlinx/coroutines/flow/MutableStateFlow;->setValue(Ljava/lang/Object;)V

    :skip_n
    invoke-interface {v5, v8}, Lkotlinx/coroutines/flow/MutableStateFlow;->setValue(Ljava/lang/Object;)V

    :done
    return-void
.end method


# virtual methods
.method public run()V
    .locals 1

    :try_start
    invoke-direct {p0}, Lradiant/RLAPILyricsWorker;->runImpl()V

    :try_end
    .catchall {:try_start .. :try_end} :catch_all

    return-void

    :catch_all
    move-exception v0

    return-void
.end method
