
// A Programmable Beeper with 16-bit Sound Data and a 1-bit Trigger.

// Sound data format:
//   Bits 15..8: MIDI note number (A4 = 69 = 0x45)
//   Bits  7..0: Exponential duration code (20ms to 5000ms)

package com.sal16.chips;

import com.cburch.logisim.data.*;
import com.cburch.logisim.instance.*;
import com.cburch.logisim.util.GraphicsUtil;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;

class Beeper extends InstanceFactory {
    Beeper() {
        super("Beeper");

        setAttributes(
                new Attribute[] { StdAttr.WIDTH, StdAttr.LABEL, StdAttr.LABEL_FONT },
                new Object[] { BitWidth.create(16), "", StdAttr.DEFAULT_LABEL_FONT });

        setOffsetBounds(Bounds.create(0, -30, 80, 70));

        setPorts(new Port[] {
                new Port(0, 0, Port.INPUT, StdAttr.WIDTH),  // Sound Data
                new Port(0, 20, Port.INPUT, 1)              // Trigger
        });
    }

    protected void configureNewInstance(Instance instance) {
        Bounds bds = instance.getBounds();
        instance.setTextField(StdAttr.LABEL, StdAttr.LABEL_FONT,
                bds.getX() + bds.getWidth()/2, bds.getY() + bds.getHeight()/2 + 10,
                GraphicsUtil.H_CENTER, GraphicsUtil.V_BASELINE);
    }

    public void propagate(InstanceState state) {
        BeeperData cur = BeeperData.get(state);

        if (cur.updateTrigger(state.getPortValue(1))) {
            int soundData = state.getPortValue(0).toIntValue() & 0xffff;
            int noteCode = (soundData >>> 8) & 0xff;
            int durationCode = soundData & 0xff;

            int calculatedFrequencyHz = (int)Math.round(
                    440.0 * Math.pow(2.0, (noteCode - 69) / 12.0));
            final int frequencyHz =
                    Math.max(20, Math.min(10000, calculatedFrequencyHz));
            final int durationMs = (int)Math.round(
                    20.0 * Math.pow(250.0, durationCode / 255.0));

            new Thread(() -> playTone(frequencyHz, durationMs), "Beeper").start();
        }
    }

    private static void playTone(int frequencyHz, int durationMs) {
        float sampleRate = 44100.0f;
        AudioFormat format = new AudioFormat(sampleRate, 8, 1, true, false);

        try (SourceDataLine line = AudioSystem.getSourceDataLine(format)) {
            line.open(format);
            line.start();

            int samples = (int)((durationMs / 1000.0) * sampleRate);
            byte[] buffer = new byte[samples];

            for (int i = 0; i < samples; i++) {
                double angle = 2.0 * Math.PI * i * frequencyHz / sampleRate;
                buffer[i] = (byte)(Math.sin(angle) * 80);
            }

            line.write(buffer, 0, buffer.length);
            line.drain();
        }
        catch (LineUnavailableException e) {
            System.err.println("Beeper audio unavailable: " + e.getMessage());
        }
    }

    public void paintInstance(InstancePainter painter) {
        painter.drawRectangle(painter.getBounds(), "BEEP");
        painter.drawPort(0, "DATA", Direction.EAST);
        painter.drawPort(1, "TRIG", Direction.EAST);
        painter.drawLabel();
    }
}

