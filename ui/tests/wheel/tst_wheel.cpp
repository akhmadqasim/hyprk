// Trackpad scrolling into RubberBand (ui/HyprK/RubberBand.qml) and into a plain Qt Flickable, offscreen.
// Events are built like the Wayland QPA builds them (qwaylandinputdevice.cpp, Qt 6.10): ScrollBegin and ScrollEnd
// with no delta and source MouseEventNotSynthesized, ScrollUpdate with a pixel delta and source
// MouseEventSynthesizedBySystem and an angle delta of 12 x the pixel delta (FrameData::angleDelta), timestamps
// increasing. A mouse wheel is NoScrollPhase with an angle delta.
#include <QtTest>
#include <QQuickView>
#include <QQuickItem>
#include <QPointingDevice>
#include <cmath>

static double elastic(double d, double D) { return (d < 0 ? -1 : 1) * D * (1 - 1 / (1 + std::abs(d) * 0.075 / D)); }

class TstWheel : public QObject {
    Q_OBJECT
    QQuickView view;
    QQuickItem *list = nullptr, *plain = nullptr, *rb = nullptr;
    ulong ts = 1000;

    void send(QQuickItem *over, Qt::ScrollPhase phase, QPoint pixel, QPoint angle = {},
              Qt::MouseEventSource src = Qt::MouseEventSynthesizedBySystem) {
        const QPointF p = over->mapToScene(QPointF(over->width() / 2, over->height() / 2));
        QWheelEvent ev(p, view.mapToGlobal(p.toPoint()), pixel, angle, Qt::NoButton, Qt::NoModifier, phase, false, src,
                       QPointingDevice::primaryPointingDevice());
        ev.setTimestamp(ts += 8);
        QCoreApplication::sendEvent(&view, &ev);
    }
    void trackpad(QQuickItem *over, const QList<int> &dys, int waitMs = 8) {
        send(over, Qt::ScrollBegin, {}, {}, Qt::MouseEventNotSynthesized);
        for (int dy : dys) { send(over, Qt::ScrollUpdate, QPoint(0, dy), QPoint(0, 12 * dy)); QTest::qWait(waitMs); }
    }
    void end(QQuickItem *over) { send(over, Qt::ScrollEnd, {}, {}, Qt::MouseEventNotSynthesized); }
    static qreal y(QQuickItem *f) { return f->property("contentY").toReal(); }
    static void setY(QQuickItem *f, qreal v) { f->setProperty("contentY", v); }

private slots:
    void initTestCase() {
        view.setSource(QUrl::fromLocalFile(QStringLiteral(FIXTURE)));
        QCOMPARE(view.status(), QQuickView::Ready);
        view.show();
        QVERIFY(QTest::qWaitForWindowExposed(&view));
        list = view.rootObject()->findChild<QQuickItem *>("list");
        plain = view.rootObject()->findChild<QQuickItem *>("plain");
        rb = view.rootObject()->findChild<QQuickItem *>("rb");
        QVERIFY(list && plain && rb);
    }

    // Why synthetic trackpad events "never reached" a Flickable before: QQuickDeliveryAgent drops a ScrollUpdate
    // with a null angle delta once the previous wheel event was accepted (it takes it for a "compatibility" copy);
    // QQuickFlickable::wheelEvent uses the angle delta, not the pixel delta, for source MouseEventNotSynthesized
    // and drops events whose timestamp did not advance; and with OvershootBounds a trackpad scroll (a drag in
    // Flickable) stops at the edge.
    void plainFlickable() {
        setY(plain, 500);
        send(plain, Qt::ScrollBegin, {}, {}, Qt::MouseEventNotSynthesized);
        send(plain, Qt::ScrollUpdate, QPoint(0, -40), {}, Qt::MouseEventNotSynthesized);
        QCOMPARE(y(plain), 500.0);                       // no angle delta, not synthesized: nothing
        for (int i = 0; i < 4; i++) { send(plain, Qt::ScrollUpdate, QPoint(0, -40), QPoint(0, -480)); QTest::qWait(8); }
        QTRY_VERIFY_WITH_TIMEOUT(y(plain) != 500, 500);  // as Wayland sends it: it scrolls
        qInfo() << "plain Flickable after 4 x 40 pt:" << y(plain);
        end(plain);
        setY(plain, 0);
        QTest::qWait(50);
        trackpad(plain, {30, 30, 30, 30});
        QCOMPARE(y(plain), 0.0);                         // OvershootBounds: no stretch at the top
        end(plain);
    }

    void stretchAndReturn() {
        setY(list, 0);
        trackpad(list, {6, 6, 30, 30}, 4);                // 72 pt down at the top (the first 10 pt show nothing)
        const double expect = -std::floor(elastic(72, 300));
        QVERIFY2(std::abs(y(list) - expect) < 1e-6, qPrintable(QString::number(y(list)) + " vs " + QString::number(expect)));
        QVariant stretched;
        QVERIFY(QMetaObject::invokeMethod(rb, "stretched", Q_RETURN_ARG(QVariant, stretched)));
        QVERIFY(stretched.toBool());
        QTest::qWait(120);                               // fingers rest: no velocity at lift
        end(list);
        QVERIFY(rb->property("animating").toBool());
        QTest::qWait(100);                               // exp(-12.5 * 0.1) = 0.29 of the stretch, frames are coarse
        const double mid = -y(list);
        QVERIFY2(mid > 0 && mid < -expect * 0.6, qPrintable(QString::number(mid)));
        QTRY_VERIFY_WITH_TIMEOUT(!rb->property("animating").toBool(), 2000);
        QCOMPARE(y(list), 0.0);
    }

    void pushBackInsideTheSameGesture() {
        setY(list, 0);
        trackpad(list, {40, -20, -100});                 // stretch, ease it off, then scroll down 1:1
        QVERIFY(y(list) > 0);
        QTest::qWait(120);
        end(list);
        QTRY_VERIFY_WITH_TIMEOUT(!rb->property("animating").toBool(), 2000);
        QVERIFY(y(list) > 0);
    }

    void mouseWheelStopsAtTheEdge() {
        setY(list, 0);
        send(list, Qt::NoScrollPhase, {}, QPoint(0, 120), Qt::MouseEventNotSynthesized);
        QTest::qWait(400);
        QCOMPARE(y(list), 0.0);
        QVERIFY(!rb->property("animating").toBool());
        send(list, Qt::NoScrollPhase, {}, QPoint(0, -120), Qt::MouseEventNotSynthesized);
        QTRY_VERIFY_WITH_TIMEOUT(y(list) > 0, 1000);     // and the wheel still reaches the ListView
        QTest::qWait(400);
    }

    void momentumCoastsAndBouncesAtTheEnd() {
        const qreal hi = 1000 * 20 - 300;
        setY(list, hi - 200);
        trackpad(list, {-20, -20, -20, -20, -20}, 8);     // ~2000 pt/s downwards at lift
        const qreal lift = y(list);
        end(list);
        QVERIFY(rb->property("animating").toBool());
        qreal peak = lift;
        QElapsedTimer t; t.start();
        while (rb->property("animating").toBool() && t.elapsed() < 3000) { QTest::qWait(5); peak = qMax(peak, y(list)); }
        QVERIFY2(peak > hi + 1, qPrintable(QString::number(peak - hi)));   // overshot the end by its velocity
        QVERIFY(peak < hi + 40);
        QCOMPARE(y(list), hi);
    }

    void sidewaysGestureIsPassedOn() {                   // a vertical list leaves a horizontal swipe to what is below
        setY(list, 100);
        send(list, Qt::ScrollBegin, {}, {}, Qt::MouseEventNotSynthesized);
        for (int i = 0; i < 4; i++) { send(list, Qt::ScrollUpdate, QPoint(-30, 2), QPoint(-360, 24)); QTest::qWait(8); }
        end(list);
        QCOMPARE(y(list), 100.0);
        QCOMPARE(list->property("contentX").toReal(), 0.0);
        QVERIFY(!rb->property("animating").toBool());
    }

    void stillVirtualised() {
        int n = 0;
        for (QQuickItem *c : list->property("contentItem").value<QQuickItem *>()->childItems()) n += c->isVisible();
        QVERIFY2(n < 60, qPrintable(QString::number(n)));
    }
};

QTEST_MAIN(TstWheel)
#include "tst_wheel.moc"
