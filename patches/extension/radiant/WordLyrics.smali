.class public final Lradiant/WordLyrics;
.super Ljava/lang/Object;

# Word-level lyrics highlighting support for the RL-API lyrics injection.
# Parses the API "Word" payload (per-line syllabus[]) into per-line word arrays,
# runs a 50ms main-thread clock that publishes an interpolated playhead into a Compose
# MutableState, and builds a two-tone AnnotatedString (sung / unsung) that the patched
# PlayerScreen line composable (f2) renders for whatever line Compose marks active.
# Line-level data (scroll, line index) still comes from TIDAL's own g$c pipeline.
#
# ROBUSTNESS: render() gates on Compose's OWN active-line index (f2.b) — not a clock
# guess — and the active line ALWAYS reads the playhead state, so it can never lose its
# recomposition subscription and get stranded on line-highlighting.


# static state

.field public static lineStarts:[J

.field public static lineWordText:[[Ljava/lang/String;

.field public static lineWordStart:[[J

.field public static volatile playheadState:Landroidx/compose/runtime/MutableState;

# active RL line index (from clock over lineStarts)
.field public static volatile activeLineState:Landroidx/compose/runtime/MutableState;

.field public static volatile baseMs:J

.field public static volatile baseAnchor:J

.field public static volatile ticking:Z

# per-render scratch handed to styleSpot
.field public static tmpStarts:[J

.field public static tmpOffs:[I

.field public static tmpN:I

.field public static tmpNow:J

.field public static tmpSung:J

.field public static tmpUnsung:J

.field public static handler:Landroid/os/Handler;

.field public static tickRunnable:Ljava/lang/Runnable;

.field public static sungColor:J

.field public static sungSpan:Landroidx/compose/ui/text/SpanStyle;

.field public static unsungColor:J

.field public static unsungSpan:Landroidx/compose/ui/text/SpanStyle;


.method private constructor <init>()V
    .locals 0

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# snapshot state (interpolated playhead ms)

.method public static state()Landroidx/compose/runtime/MutableState;
    .locals 2

    sget-object v0, Lradiant/WordLyrics;->playheadState:Landroidx/compose/runtime/MutableState;

    if-nez v0, :ret

    const/4 v0, 0x0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static {}, Landroidx/compose/runtime/SnapshotStateKt;->structuralEqualityPolicy()Landroidx/compose/runtime/SnapshotMutationPolicy;

    move-result-object v1

    invoke-static {v0, v1}, Landroidx/compose/runtime/SnapshotStateKt;->mutableStateOf(Ljava/lang/Object;Landroidx/compose/runtime/SnapshotMutationPolicy;)Landroidx/compose/runtime/MutableState;

    move-result-object v0

    sput-object v0, Lradiant/WordLyrics;->playheadState:Landroidx/compose/runtime/MutableState;

    :ret
    return-object v0
.end method

# active-line snapshot state (init -1)
.method public static lineState()Landroidx/compose/runtime/MutableState;
    .locals 2

    sget-object v0, Lradiant/WordLyrics;->activeLineState:Landroidx/compose/runtime/MutableState;

    if-nez v0, :ret

    const/4 v0, -0x1

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static {}, Landroidx/compose/runtime/SnapshotStateKt;->structuralEqualityPolicy()Landroidx/compose/runtime/SnapshotMutationPolicy;

    move-result-object v1

    invoke-static {v0, v1}, Landroidx/compose/runtime/SnapshotStateKt;->mutableStateOf(Ljava/lang/Object;Landroidx/compose/runtime/SnapshotMutationPolicy;)Landroidx/compose/runtime/MutableState;

    move-result-object v0

    sput-object v0, Lradiant/WordLyrics;->activeLineState:Landroidx/compose/runtime/MutableState;

    :ret
    return-object v0
.end method

.method public static setData([J[[Ljava/lang/String;[[J)V
    .locals 0

    sput-object p0, Lradiant/WordLyrics;->lineStarts:[J

    sput-object p1, Lradiant/WordLyrics;->lineWordText:[[Ljava/lang/String;

    sput-object p2, Lradiant/WordLyrics;->lineWordStart:[[J

    invoke-static {}, Lradiant/WordLyrics;->state()Landroidx/compose/runtime/MutableState;

    invoke-static {}, Lradiant/WordLyrics;->lineState()Landroidx/compose/runtime/MutableState;

    invoke-static {}, Lradiant/WordLyrics;->startClock()V

    return-void
.end method

.method public static clear()V
    .locals 1

    const/4 v0, 0x0

    sput-object v0, Lradiant/WordLyrics;->lineStarts:[J

    sput-object v0, Lradiant/WordLyrics;->lineWordText:[[Ljava/lang/String;

    sput-object v0, Lradiant/WordLyrics;->lineWordStart:[[J

    invoke-static {}, Lradiant/WordLyrics;->stopClock()V

    return-void
.end method

.method public static onProgress(J)V
    .locals 4

    sput-wide p0, Lradiant/WordLyrics;->baseMs:J

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v0

    sput-wide v0, Lradiant/WordLyrics;->baseAnchor:J

    # self-heal: restart the clock if data is present but it stopped
    sget-object v2, Lradiant/WordLyrics;->lineWordText:[[Ljava/lang/String;

    if-eqz v2, :done_op

    sget-boolean v2, Lradiant/WordLyrics;->ticking:Z

    if-nez v2, :done_op

    invoke-static {}, Lradiant/WordLyrics;->startClock()V

    :done_op
    return-void
.end method


# Clock

.method public static startClock()V
    .locals 2

    sget-boolean v0, Lradiant/WordLyrics;->ticking:Z

    if-nez v0, :done

    const/4 v0, 0x1

    sput-boolean v0, Lradiant/WordLyrics;->ticking:Z

    sget-object v0, Lradiant/WordLyrics;->handler:Landroid/os/Handler;

    if-nez v0, :have_h

    new-instance v0, Landroid/os/Handler;

    invoke-static {}, Landroid/os/Looper;->getMainLooper()Landroid/os/Looper;

    move-result-object v1

    invoke-direct {v0, v1}, Landroid/os/Handler;-><init>(Landroid/os/Looper;)V

    sput-object v0, Lradiant/WordLyrics;->handler:Landroid/os/Handler;

    :have_h
    sget-object v0, Lradiant/WordLyrics;->tickRunnable:Ljava/lang/Runnable;

    if-nez v0, :have_r

    new-instance v0, Lradiant/WordLyricsTick;

    invoke-direct {v0}, Lradiant/WordLyricsTick;-><init>()V

    sput-object v0, Lradiant/WordLyrics;->tickRunnable:Ljava/lang/Runnable;

    :have_r
    sget-object v0, Lradiant/WordLyrics;->handler:Landroid/os/Handler;

    sget-object v1, Lradiant/WordLyrics;->tickRunnable:Ljava/lang/Runnable;

    invoke-virtual {v0, v1}, Landroid/os/Handler;->post(Ljava/lang/Runnable;)Z

    :done
    return-void
.end method

.method public static stopClock()V
    .locals 2

    const/4 v0, 0x0

    sput-boolean v0, Lradiant/WordLyrics;->ticking:Z

    sget-object v0, Lradiant/WordLyrics;->handler:Landroid/os/Handler;

    if-eqz v0, :ret

    sget-object v1, Lradiant/WordLyrics;->tickRunnable:Ljava/lang/Runnable;

    if-eqz v1, :ret

    invoke-virtual {v0, v1}, Landroid/os/Handler;->removeCallbacks(Ljava/lang/Runnable;)V

    :ret
    return-void
.end method

.method static computeNow()J
    .locals 7

    sget-wide v0, Lradiant/WordLyrics;->baseMs:J

    sget-wide v2, Lradiant/WordLyrics;->baseAnchor:J

    invoke-static {}, Landroid/os/SystemClock;->elapsedRealtime()J

    move-result-wide v4

    sub-long/2addr v4, v2

    const-wide/16 v2, 0x0

    cmp-long v6, v4, v2

    if-gez v6, :chk_hi

    move-wide v4, v2

    goto :add

    :chk_hi
    const-wide/16 v2, 0x190

    cmp-long v6, v4, v2

    if-lez v6, :add

    move-wide v4, v2

    :add
    add-long/2addr v0, v4

    return-wide v0
.end method

# largest index i with arr[i] <= v, else -1 (arr ascending)
.method static search([JJ)I
    .locals 5

    const/4 v0, -0x1

    if-eqz p0, :done

    array-length v1, p0

    const/4 v2, 0x0

    :loop
    if-ge v2, v1, :done

    aget-wide v3, p0, v2

    cmp-long v4, v3, p1

    if-gtz v4, :done

    move v0, v2

    add-int/lit8 v2, v2, 0x1

    goto :loop

    :done
    return v0
.end method

# 33ms tick: publish the interpolated playhead + the active RL line into snapshot states
.method public static tick()V
    .locals 6

    sget-object v0, Lradiant/WordLyrics;->lineWordText:[[Ljava/lang/String;

    if-eqz v0, :stop

    invoke-static {}, Lradiant/WordLyrics;->computeNow()J

    move-result-wide v0

    # active RL line index (search over lineStarts)
    sget-object v2, Lradiant/WordLyrics;->lineStarts:[J

    invoke-static {v2, v0, v1}, Lradiant/WordLyrics;->search([JJ)I

    move-result v2

    invoke-static {}, Lradiant/WordLyrics;->lineState()Landroidx/compose/runtime/MutableState;

    move-result-object v3

    invoke-interface {v3}, Landroidx/compose/runtime/MutableState;->getValue()Ljava/lang/Object;

    move-result-object v4

    if-eqz v4, :set_al

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v5

    if-eq v5, v2, :al_done

    :set_al
    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v4

    invoke-interface {v3, v4}, Landroidx/compose/runtime/MutableState;->setValue(Ljava/lang/Object;)V

    :al_done
    # playhead tick (every frame) -> playheadState (drives active line fade)
    long-to-int v0, v0

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v0

    invoke-static {}, Lradiant/WordLyrics;->state()Landroidx/compose/runtime/MutableState;

    move-result-object v1

    invoke-interface {v1, v0}, Landroidx/compose/runtime/MutableState;->setValue(Ljava/lang/Object;)V

    sget-boolean v0, Lradiant/WordLyrics;->ticking:Z

    if-eqz v0, :done

    sget-object v0, Lradiant/WordLyrics;->handler:Landroid/os/Handler;

    if-eqz v0, :done

    sget-object v1, Lradiant/WordLyrics;->tickRunnable:Ljava/lang/Runnable;

    if-eqz v1, :done

    const-wide/16 v2, 0x21

    invoke-virtual {v0, v1, v2, v3}, Landroid/os/Handler;->postDelayed(Ljava/lang/Runnable;J)Z

    :done
    return-void

    :stop
    const/4 v0, 0x0

    sput-boolean v0, Lradiant/WordLyrics;->ticking:Z

    return-void
.end method


# render

.method public static render(IILjava/lang/String;JJ)Landroidx/compose/ui/text/AnnotatedString;
    .locals 18

    move/from16 v15, p0

    move-object/from16 v10, p2

    move-wide/from16 v11, p3

    move-wide/from16 v13, p5

    # only style lines that have RL word data
    sget-boolean v0, Lradiant/RLAPILyricsHook;->isRlState:Z

    if-eqz v0, :plain

    sget-object v0, Lradiant/WordLyrics;->lineWordText:[[Ljava/lang/String;

    if-eqz v0, :plain

    if-ltz v15, :plain

    array-length v1, v0

    if-ge v15, v1, :plain

    aget-object v1, v0, v15

    if-eqz v1, :plain

    array-length v2, v1

    if-eqz v2, :plain

    sget-object v3, Lradiant/WordLyrics;->lineWordStart:[[J

    if-eqz v3, :plain

    aget-object v3, v3, v15

    if-eqz v3, :plain

    # build line text + per word char offsets (offsets[n] = total length)
    new-instance v6, Landroidx/compose/ui/text/AnnotatedString$Builder;

    invoke-direct {v6}, Landroidx/compose/ui/text/AnnotatedString$Builder;-><init>()V

    add-int/lit8 v8, v2, 0x1

    new-array v7, v8, [I

    const/4 v8, 0x0

    const/4 v9, 0x0

    :aloop
    if-ge v8, v2, :adone

    aput v9, v7, v8

    aget-object v0, v1, v8

    invoke-virtual {v6, v0}, Landroidx/compose/ui/text/AnnotatedString$Builder;->append(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v0

    add-int/2addr v9, v0

    add-int/lit8 v8, v8, 0x1

    goto :aloop

    :adone
    aput v9, v7, v2

    # base grey span over the whole line (stops flicker)
    const/4 v0, 0x0

    invoke-static {v13, v14, v0}, Lradiant/WordLyrics;->span(JZ)Landroidx/compose/ui/text/SpanStyle;

    move-result-object v0

    const/4 v8, 0x0

    invoke-virtual {v6, v0, v8, v9}, Landroidx/compose/ui/text/AnnotatedString$Builder;->addStyle(Landroidx/compose/ui/text/SpanStyle;II)V

    # active line = clocks line
    invoke-static {}, Lradiant/WordLyrics;->lineState()Landroidx/compose/runtime/MutableState;

    move-result-object v0

    invoke-interface {v0}, Landroidx/compose/runtime/MutableState;->getValue()Ljava/lang/Object;

    move-result-object v0

    const/4 v4, -0x1

    if-eqz v0, :have_al

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v4

    :have_al
    if-ne v15, v4, :emit

    # active line subscribes to the playhead tick (fade) & create/use a fresh playhead
    invoke-static {}, Lradiant/WordLyrics;->state()Landroidx/compose/runtime/MutableState;

    move-result-object v0

    invoke-interface {v0}, Landroidx/compose/runtime/MutableState;->getValue()Ljava/lang/Object;

    invoke-static {}, Lradiant/WordLyrics;->computeNow()J

    move-result-wide v4

    invoke-static {v3, v4, v5}, Lradiant/WordLyrics;->search([JJ)I

    move-result v8

    if-ltz v8, :emit

    # spotlight (only the active word is highlighted)

    sput-object v3, Lradiant/WordLyrics;->tmpStarts:[J

    sput-object v7, Lradiant/WordLyrics;->tmpOffs:[I

    sput v2, Lradiant/WordLyrics;->tmpN:I

    sput-wide v4, Lradiant/WordLyrics;->tmpNow:J

    sput-wide v11, Lradiant/WordLyrics;->tmpSung:J

    sput-wide v13, Lradiant/WordLyrics;->tmpUnsung:J

    invoke-static {v6, v8}, Lradiant/WordLyrics;->styleSpot(Landroidx/compose/ui/text/AnnotatedString$Builder;I)V

    :emit
    invoke-virtual {v6}, Landroidx/compose/ui/text/AnnotatedString$Builder;->toAnnotatedString()Landroidx/compose/ui/text/AnnotatedString;

    move-result-object v0

    return-object v0

    :plain
    new-instance v0, Landroidx/compose/ui/text/AnnotatedString$Builder;

    invoke-direct {v0, v10}, Landroidx/compose/ui/text/AnnotatedString$Builder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Landroidx/compose/ui/text/AnnotatedString$Builder;->toAnnotatedString()Landroidx/compose/ui/text/AnnotatedString;

    move-result-object v0

    return-object v0
.end method

# Colour the single active word j (faded grey<->white by its bump curve)
.method static styleSpot(Landroidx/compose/ui/text/AnnotatedString$Builder;I)V
    .locals 12

    sget v0, Lradiant/WordLyrics;->tmpN:I

    if-ltz p1, :done

    if-ge p1, v0, :done

    sget-object v1, Lradiant/WordLyrics;->tmpStarts:[J

    aget-wide v2, v1, p1

    add-int/lit8 v4, p1, 0x1

    if-ge v4, v0, :last_w

    aget-wide v4, v1, v4

    goto :have_we

    :last_w
    const-wide/16 v4, 0x320

    add-long/2addr v4, v2

    :have_we
    sget-wide v6, Lradiant/WordLyrics;->tmpNow:J

    invoke-static/range {v2 .. v7}, Lradiant/WordLyrics;->bump(JJJ)F

    move-result v8

    const v9, 0x3c23d70a

    cmpg-float v10, v8, v9

    if-lez v10, :done

    sget-wide v0, Lradiant/WordLyrics;->tmpUnsung:J

    sget-wide v2, Lradiant/WordLyrics;->tmpSung:J

    invoke-static {v0, v1, v2, v3, v8}, Landroidx/compose/ui/graphics/ColorKt;->lerp-jxsXWHM(JJF)J

    move-result-wide v0

    invoke-static {v0, v1}, Lradiant/WordLyrics;->makeSpan(J)Landroidx/compose/ui/text/SpanStyle;

    move-result-object v0

    sget-object v1, Lradiant/WordLyrics;->tmpOffs:[I

    aget v2, v1, p1

    add-int/lit8 v3, p1, 0x1

    aget v3, v1, v3

    invoke-virtual {p0, v0, v2, v3}, Landroidx/compose/ui/text/AnnotatedString$Builder;->addStyle(Landroidx/compose/ui/text/SpanStyle;II)V

    :done
    return-void
.end method

# Fade Curve (tech blabble below)
# Fade curve for a word active over [ws, we) ramps 0 -> 1 over the first FADE ms & 1 -> 0 over the last FADE ms (min of the two ramps) 0 outside the window
.method static bump(JJJ)F
    .locals 6

    cmp-long v0, p4, p0

    if-ltz v0, :zero

    cmp-long v0, p4, p2

    if-gez v0, :zero

    sub-long v0, p4, p0

    long-to-float v0, v0

    const v1, 0x42f00000

    div-float v0, v0, v1

    sub-long v2, p2, p4

    long-to-float v2, v2

    div-float v2, v2, v1

    cmpg-float v3, v0, v2

    if-lez v3, :have_min

    move v0, v2

    :have_min
    const v1, 0x3f800000

    cmpg-float v3, v0, v1

    if-lez v3, :ret

    move v0, v1

    :ret
    return v0

    :zero
    const/4 v0, 0x0

    return v0
.end method

# cached SpanStyle per color (p2=isSung slot)
.method static span(JZ)Landroidx/compose/ui/text/SpanStyle;
    .locals 3

    if-eqz p2, :unsung

    sget-object v0, Lradiant/WordLyrics;->sungSpan:Landroidx/compose/ui/text/SpanStyle;

    if-eqz v0, :build_s

    sget-wide v1, Lradiant/WordLyrics;->sungColor:J

    cmp-long v2, v1, p0

    if-nez v2, :build_s

    return-object v0

    :build_s
    invoke-static {p0, p1}, Lradiant/WordLyrics;->makeSpan(J)Landroidx/compose/ui/text/SpanStyle;

    move-result-object v0

    sput-object v0, Lradiant/WordLyrics;->sungSpan:Landroidx/compose/ui/text/SpanStyle;

    sput-wide p0, Lradiant/WordLyrics;->sungColor:J

    return-object v0

    :unsung
    sget-object v0, Lradiant/WordLyrics;->unsungSpan:Landroidx/compose/ui/text/SpanStyle;

    if-eqz v0, :build_u

    sget-wide v1, Lradiant/WordLyrics;->unsungColor:J

    cmp-long v2, v1, p0

    if-nez v2, :build_u

    return-object v0

    :build_u
    invoke-static {p0, p1}, Lradiant/WordLyrics;->makeSpan(J)Landroidx/compose/ui/text/SpanStyle;

    move-result-object v0

    sput-object v0, Lradiant/WordLyrics;->unsungSpan:Landroidx/compose/ui/text/SpanStyle;

    sput-wide p0, Lradiant/WordLyrics;->unsungColor:J

    return-object v0
.end method

# SpanStyle(color = <p0>) with every other property defaulted (mask 0xFFFE, bit0 clear = provide color)
.method static makeSpan(J)Landroidx/compose/ui/text/SpanStyle;
    .locals 23

    new-instance v0, Landroidx/compose/ui/text/SpanStyle;

    move-wide/from16 v1, p0

    const-wide/16 v3, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const-wide/16 v10, 0x0

    const/4 v12, 0x0

    const/4 v13, 0x0

    const/4 v14, 0x0

    const-wide/16 v15, 0x0

    const/16 v17, 0x0

    const/16 v18, 0x0

    const/16 v19, 0x0

    const/16 v20, 0x0

    const v21, 0xfffe

    const/16 v22, 0x0

    invoke-direct/range {v0 .. v22}, Landroidx/compose/ui/text/SpanStyle;-><init>(JJLandroidx/compose/ui/text/font/FontWeight;Landroidx/compose/ui/text/font/FontStyle;Landroidx/compose/ui/text/font/FontSynthesis;Landroidx/compose/ui/text/font/FontFamily;Ljava/lang/String;JLandroidx/compose/ui/text/style/BaselineShift;Landroidx/compose/ui/text/style/TextGeometricTransform;Landroidx/compose/ui/text/intl/LocaleList;JLandroidx/compose/ui/text/style/TextDecoration;Landroidx/compose/ui/graphics/Shadow;Landroidx/compose/ui/text/PlatformSpanStyle;Landroidx/compose/ui/graphics/drawscope/DrawStyle;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-object v0
.end method


# ingest API ("Word" payload into per line word arrays)

.method public static ingest(Ljava/lang/String;)V
    .locals 20

    :try_start
    move-object/from16 v9, p0

    new-instance v6, Lorg/json/JSONObject;

    invoke-direct {v6, v9}, Lorg/json/JSONObject;-><init>(Ljava/lang/String;)V

    const-string v7, "type"

    const-string v8, ""

    invoke-virtual {v6, v7, v8}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    const-string v8, "Word"

    invoke-virtual {v8, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v7

    if-nez v7, :is_word

    const-string v7, "WordLyrics ingest: not Word type -> cleared"

    invoke-static {v7}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    invoke-static {}, Lradiant/WordLyrics;->clear()V

    return-void

    :is_word
    const-string v7, "data"

    invoke-virtual {v6, v7}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v0

    if-nez v0, :have_data

    invoke-static {}, Lradiant/WordLyrics;->clear()V

    return-void

    :have_data
    invoke-virtual {v0}, Lorg/json/JSONArray;->length()I

    move-result v1

    if-nez v1, :nonempty

    invoke-static {}, Lradiant/WordLyrics;->clear()V

    return-void

    :nonempty
    new-array v2, v1, [J

    new-array v3, v1, [[Ljava/lang/String;

    new-array v4, v1, [[J

    const/4 v5, 0x0

    :line_loop
    if-ge v5, v1, :lines_done

    invoke-virtual {v0, v5}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v6

    const-string v7, "startTime"

    const-wide/16 v8, 0x0

    invoke-virtual {v6, v7, v8, v9}, Lorg/json/JSONObject;->optDouble(Ljava/lang/String;D)D

    move-result-wide v7

    const-wide v9, 0x408f400000000000L

    mul-double/2addr v7, v9

    double-to-long v7, v7

    aput-wide v7, v2, v5

    const-string v7, "syllabus"

    invoke-virtual {v6, v7}, Lorg/json/JSONObject;->optJSONArray(Ljava/lang/String;)Lorg/json/JSONArray;

    move-result-object v7

    if-eqz v7, :single

    invoke-virtual {v7}, Lorg/json/JSONArray;->length()I

    move-result v8

    if-nez v8, :have_syl

    :single
    const/4 v8, 0x1

    new-array v9, v8, [Ljava/lang/String;

    const-string v10, "text"

    const-string v11, ""

    invoke-virtual {v6, v10, v11}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v10

    const/4 v11, 0x0

    aput-object v10, v9, v11

    aput-object v9, v3, v5

    new-array v9, v8, [J

    aget-wide v7, v2, v5

    aput-wide v7, v9, v11

    aput-object v9, v4, v5

    goto :line_next

    :have_syl
    const/4 v9, 0x0

    const/4 v10, 0x0

    :count_loop
    if-ge v10, v8, :count_done

    invoke-virtual {v7, v10}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v11

    const-string v12, "text"

    const-string v13, ""

    invoke-virtual {v11, v12, v13}, Lorg/json/JSONObject;->optString(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v11

    invoke-static {v11, v10, v8}, Lradiant/WordLyrics;->isWordEnd(Ljava/lang/String;II)Z

    move-result v11

    if-eqz v11, :count_next

    add-int/lit8 v9, v9, 0x1

    :count_next
    add-int/lit8 v10, v10, 0x1

    goto :count_loop

    :count_done
    if-nez v9, :count_ok

    const/4 v9, 0x1

    :count_ok
    new-array v10, v9, [Ljava/lang/String;

    new-array v11, v9, [J

    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    const/4 v13, 0x0

    const/4 v14, 0x0

    const-wide/16 v15, 0x0

    const/16 v17, 0x0

    :fill_loop
    if-ge v13, v8, :fill_done

    invoke-virtual {v7, v13}, Lorg/json/JSONArray;->getJSONObject(I)Lorg/json/JSONObject;

    move-result-object v6

    if-nez v17, :grp_open

    const-string v9, "time"

    invoke-virtual {v6, v9}, Lorg/json/JSONObject;->optLong(Ljava/lang/String;)J

    move-result-wide v15

    const/16 v17, 0x1

    :grp_open
    const-string v9, "text"

    invoke-virtual {v6, v9}, Lorg/json/JSONObject;->optString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v12, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    invoke-static {v6, v13, v8}, Lradiant/WordLyrics;->isWordEnd(Ljava/lang/String;II)Z

    move-result v6

    if-eqz v6, :fill_next

    invoke-virtual {v12}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    aput-object v6, v10, v14

    aput-wide v15, v11, v14

    add-int/lit8 v14, v14, 0x1

    new-instance v12, Ljava/lang/StringBuilder;

    invoke-direct {v12}, Ljava/lang/StringBuilder;-><init>()V

    const/16 v17, 0x0

    :fill_next
    add-int/lit8 v13, v13, 0x1

    goto :fill_loop

    :fill_done
    aput-object v10, v3, v5

    aput-object v11, v4, v5

    :line_next
    # use the first WORD's start as the line's start so the active-line clock and the word times come from the same source (API line startTime can precede its words btw)
    aget-object v6, v4, v5

    const/4 v7, 0x0

    aget-wide v8, v6, v7

    aput-wide v8, v2, v5

    add-int/lit8 v5, v5, 0x1

    goto :line_loop

    :lines_done
    new-instance v6, Ljava/lang/StringBuilder;

    const-string v7, "WordLyrics ingest: Word, lines="

    invoke-direct {v6, v7}, Ljava/lang/StringBuilder;-><init>(Ljava/lang/String;)V

    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v6}, Lradiant/RLAPILyricsHook;->dlog(Ljava/lang/String;)V

    invoke-static {v2, v3, v4}, Lradiant/WordLyrics;->setData([J[[Ljava/lang/String;[[J)V

    return-void

    :try_end
    .catchall {:try_start .. :try_end} :catch

    :catch
    move-exception v0

    invoke-static {}, Lradiant/WordLyrics;->clear()V

    return-void
.end method

# boundary if last char is whitespace or last syllable in the line
.method static isWordEnd(Ljava/lang/String;II)Z
    .locals 3

    add-int/lit8 v0, p2, -0x1

    if-ne p1, v0, :not_last

    const/4 v0, 0x1

    return v0

    :not_last
    invoke-virtual {p0}, Ljava/lang/String;->length()I

    move-result v0

    if-nez v0, :has_len

    const/4 v0, 0x0

    return v0

    :has_len
    add-int/lit8 v1, v0, -0x1

    invoke-virtual {p0, v1}, Ljava/lang/String;->charAt(I)C

    move-result v1

    invoke-static {v1}, Ljava/lang/Character;->isWhitespace(C)Z

    move-result v1

    return v1
.end method
