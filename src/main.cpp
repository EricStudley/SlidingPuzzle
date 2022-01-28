#include <QQmlContext>
#include <QGuiApplication>
#include <QQuickImageProvider>
#include <QQmlApplicationEngine>

#include "PuzzleController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    PuzzleController *m_appCtrl = new PuzzleController(QQuickImageProvider::Image);

    engine.addImageProvider(QLatin1String("imageprovider"), m_appCtrl);
    engine.rootContext()->setContextProperty("puzzleController", m_appCtrl);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    app.exec();

    return 0;
}
