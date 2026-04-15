#ifndef CODEDECODERVIDEOSINK_H
#define CODEDECODERVIDEOSINK_H

#include <QObject>
#include <QDebug>
#include <QtConcurrent>
#include <QtMultimedia/QVideoSink>
#include <QtMultimedia/QVideoFrame>
#include <QtQml/qqmlregistration.h>
#include "QZXing.h"
#include <QByteArray>

class CodeDecoderVideoSink : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QObject* videoSink WRITE setVideoSink)
public:
    explicit CodeDecoderVideoSink(QObject *parent = nullptr){
        decoder.setDecoder(QZXing::DecoderFormat_QR_CODE);
        decoder.setSourceFilterType(QZXing::SourceFilter_ImageNormal);
        decoder.setTryHarderBehaviour(QZXing::TryHarderBehaviour_ThoroughScanning | QZXing::TryHarderBehaviour_Rotate);

        connect(&decoder, &QZXing::tagFound, this, &CodeDecoderVideoSink::onTagFound);
    }

    void setVideoSink(QObject *videoSink){
        m_videoSink = qobject_cast<QVideoSink*>(videoSink);

        connect(m_videoSink, &QVideoSink::videoFrameChanged, this, [=](const QVideoFrame &frame){
            static bool m_decoding = false;
            if(!m_decoding){
                m_decoding = true;
                auto image = frame.toImage();
                QtConcurrent::run([=](){
                    decoder.decodeImage(image, image.width(), image.height());
                    m_decoding = false;
                });
            }
        });
    }

signals:
    void tagFound(QByteArray tag);
    void qrCodeDetected();

private slots:
    void onTagFound(const QString &tag){
        emit tagFound(QByteArray::fromBase64(tag.toUtf8()));
        emit qrCodeDetected();
    }

private:
    QZXing decoder;
    QVideoSink *m_videoSink;
};

#endif // CODEDECODERVIDEOSINK_H


